<?php

namespace App\Repositories;

use App\Models\ClassRoom;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class ClassRepository
{
    public function getAll(array $filters = [])
    {
        $query = ClassRoom::with('lecturer');

        if (isset($filters['lecturer_id'])) {
            $query->where('lecturer_id', $filters['lecturer_id']);
        }

        return $query->get();
    }

    public function findById(int $id)
    {
        return ClassRoom::with('students', 'lecturer')->findOrFail($id);
    }

    public function create(array $data): ClassRoom
    {
        return ClassRoom::create($data);
    }

    public function update(int $id, array $data): ClassRoom
    {
        $class = ClassRoom::findOrFail($id);
        $class->update($data);
        return $class;
    }

    public function delete(int $id): void
    {
        ClassRoom::findOrFail($id)->delete();
    }

    public function findStudentForEnrollment(array $data): User
    {
        $query = User::query()->where('role', 'student');

        if (!empty($data['student_id'])) {
            $query->where('id', $data['student_id']);
        } elseif (!empty($data['email'])) {
            $query->where('email', $data['email']);
        } else {
            throw ValidationException::withMessages([
                'student' => ['student_id hoặc email là bắt buộc.'],
            ]);
        }

        $student = $query->first();
        if (!$student && !empty($data['email'])) {
            $student = User::create([
                'name' => $data['name'] ?? 'Sinh viên mới',
                'email' => $data['email'],
                'role' => 'student',
                'password' => Hash::make(Str::random(12)),
            ]);
        }

        if (!$student) {
            throw ValidationException::withMessages([
                'student' => ['Không tìm thấy sinh viên hợp lệ.'],
            ]);
        }

        if (!empty($data['name']) && $student->name !== $data['name']) {
            $student->name = $data['name'];
            $student->save();
        }

        return $student;
    }

    public function addStudent(int $classId, User $student): User
    {
        $class = ClassRoom::findOrFail($classId);
        $class->students()->syncWithoutDetaching([$student->id]);

        return $student;
    }

    public function removeStudent(int $classId, int $studentId): void
    {
        $class = ClassRoom::findOrFail($classId);
        $class->students()->detach($studentId);
    }

    /**
     * @throws ValidationException
     */
    public function importStudents(int $classId, array $studentsData): int
    {
        $class = ClassRoom::findOrFail($classId);
        $count = 0;

        DB::transaction(function () use ($studentsData, $class, &$count) {
            foreach ($studentsData as $studentRow) {
                $validator = Validator::make($studentRow, [
                    'email' => 'required|email',
                    'name' => 'nullable|string|max:255',
                ]);

                if ($validator->fails()) {
                    continue;
                }

                $validated = $validator->validated();
                $student = User::firstWhere('email', $validated['email']);

                if (!$student) {
                    $student = User::create([
                        'name' => $validated['name'] ?? 'Sinh viên mới',
                        'email' => $validated['email'],
                        'role' => 'student',
                        'password' => Hash::make(Str::random(12)),
                    ]);
                }

                if ($student->role === 'student') {
                    if (!empty($validated['name']) && $student->name !== $validated['name']) {
                        $student->name = $validated['name'];
                        $student->save();
                    }
                    $class->students()->syncWithoutDetaching([$student->id]);
                    $count++;
                }
            }
        });

        return $count;
    }
}


