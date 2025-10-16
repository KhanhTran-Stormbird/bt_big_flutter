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

        User::updateOrCreate(
            ['email' => 'lecturer@example.com'],
            ['name' => 'Lecturer', 'password' => Hash::make('password'), 'role' => 'lecturer']
        );

        User::updateOrCreate(
            ['email' => 'student@example.com'],
            ['name' => 'Student', 'password' => Hash::make('password'), 'role' => 'student']
        );
    }
}
