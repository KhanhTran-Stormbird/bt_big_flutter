<?php

namespace App\Repositories;

use App\Models\ClassRoom;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
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
                ]);

                if ($validator->fails()) {
                    continue;
                }

                $student = User::firstWhere('email', $validator->validated()['email']);

                if ($student && $student->role === 'student') {
                    $class->students()->syncWithoutDetaching([$student->id]);
                    $count++;
                }
            }
        });

        return $count;
    }
}