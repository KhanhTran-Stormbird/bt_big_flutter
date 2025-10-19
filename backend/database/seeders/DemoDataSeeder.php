<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Storage;
use Carbon\Carbon;
use App\Models\{
    ClassRoom,
    Session,
    Attendance,
    FaceSample,
    User
};

class DemoDataSeeder extends Seeder
{
    public function run(): void
    {
        $lecturers = User::where('role', 'lecturer')->get();
        $students = User::where('role', 'student')->get();

        if ($lecturers->isEmpty() || $students->isEmpty()) {
            return;
        }

        $classSubjects = [
            'Computer Science',
            'Information Systems',
            'Software Engineering',
            'Data Science',
            'Cyber Security',
        ];

        foreach (range(1, 5) as $index) {
            $lecturer = $lecturers->get(($index - 1) % $lecturers->count());

            $class = ClassRoom::updateOrCreate(
                ['name' => sprintf('CS10%d - Demo Class %d', $index, $index)],
                [
                    'subject' => $classSubjects[$index - 1] ?? 'Computer Science',
                    'term' => '2025' . chr(64 + $index),
                    'lecturer_id' => $lecturer->id,
                ]
            );

            $assignedStudents = $students
                ->shuffle()
                ->take(min(5, $students->count()));

            if ($assignedStudents->isNotEmpty()) {
                $class->students()->syncWithoutDetaching($assignedStudents->pluck('id')->all());
            }

            $this->seedSessionsAndAttendance($class, $assignedStudents, $index);
        }

        $this->seedFaceSamples($students);
    }

    protected function seedSessionsAndAttendance(ClassRoom $class, Collection $students, int $classIndex): void
    {
        foreach (range(1, 5) as $sessionIndex) {
            $startsAt = Carbon::now()
                ->subDays(30)
                ->addDays(($classIndex - 1) * 7 + $sessionIndex)
                ->setTime(8, 0)
                ->addMinutes($sessionIndex * 5);

            $endsAt = (clone $startsAt)->addHours(2);

            $session = Session::updateOrCreate(
                [
                    'class_id' => $class->id,
                    'starts_at' => $startsAt,
                ],
                [
                    'ends_at' => $endsAt,
                    'status' => $sessionIndex >= 4 ? 'closed' : 'open',
                    'qr_ttl' => 300,
                ]
            );

            foreach ($students as $student) {
                $checkedAt = (clone $startsAt)->addMinutes(5);
                $imagePath = sprintf('sessions/%d/students/%d/checkin.jpg', $session->id, $student->id);

                if (!Storage::disk('checkins')->exists($imagePath)) {
                    Storage::disk('checkins')->put($imagePath, 'demo');
                }

                Attendance::updateOrCreate(
                    [
                        'session_id' => $session->id,
                        'student_id' => $student->id,
                    ],
                    [
                        'status' => 'present',
                        'method' => 'qr',
                        'checked_at' => $checkedAt,
                        'image_path' => $imagePath,
                    ]
                );
            }
        }
    }

    protected function seedFaceSamples(Collection $students): void
    {
        foreach ($students as $student) {
            $path = sprintf('users/%d/sample.jpg', $student->id);

            if (!Storage::disk('faces')->exists($path)) {
                Storage::disk('faces')->put($path, 'demo');
            }

            FaceSample::updateOrCreate(
                [
                    'user_id' => $student->id,
                    'path' => $path,
                ],
                [
                    'embedding' => [],
                    'quality_score' => 0.9,
                ]
            );
        }
    }
}
