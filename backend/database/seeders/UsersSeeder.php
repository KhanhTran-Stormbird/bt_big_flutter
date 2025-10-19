<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class UsersSeeder extends Seeder
{
    public function run(): void
    {
        User::updateOrCreate(
            ['email' => 'admin@example.com'],
            ['name' => 'Admin', 'password' => Hash::make('password'), 'role' => 'admin']
        );

        $lecturers = [
            ['name' => 'Lecturer One', 'email' => 'lecturer1@example.com'],
            ['name' => 'Lecturer Two', 'email' => 'lecturer2@example.com'],
            ['name' => 'Lecturer Three', 'email' => 'lecturer3@example.com'],
            ['name' => 'Lecturer Four', 'email' => 'lecturer4@example.com'],
            ['name' => 'Lecturer Five', 'email' => 'lecturer5@example.com'],
        ];

        foreach ($lecturers as $lecturer) {
            User::updateOrCreate(
                ['email' => $lecturer['email']],
                [
                    'name' => $lecturer['name'],
                    'password' => Hash::make('password'),
                    'role' => 'lecturer',
                ]
            );
        }

        $students = [
            ['name' => 'Student One', 'email' => 'student1@example.com'],
            ['name' => 'Student Two', 'email' => 'student2@example.com'],
            ['name' => 'Student Three', 'email' => 'student3@example.com'],
            ['name' => 'Student Four', 'email' => 'student4@example.com'],
            ['name' => 'Student Five', 'email' => 'student5@example.com'],
        ];

        foreach ($students as $student) {
            User::updateOrCreate(
                ['email' => $student['email']],
                [
                    'name' => $student['name'],
                    'password' => Hash::make('password'),
                    'role' => 'student',
                ]
            );
        }
    }
}
