<?php

namespace App\Http\Controllers\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use App\Services\FaceService;
use App\Models\Attendance;

class AttendanceController extends Controller
{
    public function checkIn(Request $request, FaceService $face)
    {
        $request->validate([
            'session_token' => 'required|string',
            'image' => 'required|image|max:5120',
        ]);

        // TODO: verify session_token via QrService; for now, map demo token → session_id 1
        $sessionToken = $request->string('session_token');
        $sessionId = $sessionToken === 'demo-session-token' ? 1 : 1;

        $user = Auth::guard('api')->user();
        $stored = $request->file('image')->store('sessions/'.$sessionId.'/users/'.$user->id, 'checkins');
        $absolute = Storage::disk('checkins')->path($stored);

        $verify = $face->verify($user, $absolute);
        $status = $verify['is_match'] ? 'present' : 'suspect';

        $att = Attendance::updateOrCreate(
            ['session_id' => $sessionId, 'student_id' => $user->id],
            [
                'status' => $status,
                'method' => 'face',
                'checked_at' => now(),
                'distance' => $verify['distance'],
                'image_path' => $stored,
            ]
        );

        return response()->json([
            'id' => $att->id,
            'session_id' => $sessionId,
            'student_id' => $user->id,
            'status' => $att->status,
            'checked_at' => $att->checked_at->toDateTimeString(),
            'distance' => $att->distance,
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
