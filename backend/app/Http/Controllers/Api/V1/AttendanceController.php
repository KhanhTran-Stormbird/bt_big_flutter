<?php

namespace App\Http\Controllers\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;

class AttendanceController extends Controller
{
    public function checkIn(Request $request)
    {
        return response()->json([
            'id' => 1,
            'session_id' => 1,
            'student_id' => 1,
            'status' => 'present',
            'checked_at' => now()->toDateTimeString(),
            'distance' => 0.25,
        ]);
    }

    public function history(Request $request)
    {
        return response()->json([
            [
                'id' => 1,
                'session_id' => 1,
                'student_id' => 1,
                'status' => 'present',
                'checked_at' => now()->subDay()->toDateTimeString(),
                'distance' => 0.42,
            ],
        ]);
    }
}
