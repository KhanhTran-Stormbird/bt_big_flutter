<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\{ClassRoom, User};

class DemoDataSeeder extends Seeder
{
    public function run(): void
    {
        $lecturer = User::where('role', 'lecturer')->first();
        if ($lecturer) {
            ClassRoom::updateOrCreate(
                ['name' => 'CS101 - Intro to CS'],
                ['subject' => 'Computer Science', 'term' => '2025A', 'lecturer_id' => $lecturer->id]
            );
        }
    }
}
