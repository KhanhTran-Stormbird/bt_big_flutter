<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Repositories\AttendanceRepository;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Cache;

class AttendanceController extends Controller
{
    protected AttendanceRepository $attendanceRepository;

    public function __construct(AttendanceRepository $attendanceRepository)
    {
        $this->attendanceRepository = $attendanceRepository;
    }

    public function checkIn(Request $request): JsonResponse
    {
        $data = $request->validate([
            'session_token' => 'required|string',
            'image' => 'required|image',
        ]);

        $cacheKey = "session_token:{$data['session_token']}";
        $tokenData = Cache::get($cacheKey);

        if (!$tokenData) {
            return response()->json(['message' => 'Invalid or expired session token.'], 400);
        }

        // Invalidate the token after use
        Cache::forget($cacheKey);

        try {
            $attendance = $this->attendanceRepository->createFromQr(
                $tokenData['session_id'],
                $tokenData['student_id'],
                $request->file('image')
            );
            return response()->json($attendance, 201);
        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], 400);
        }
    }

    public function history(Request $request): JsonResponse
    {
        $user = $request->user();
        $filters = $request->validate([
            'class_id' => 'sometimes|integer|exists:classes,id',
            'student_id' => 'sometimes|integer|exists:users,id',
        ]);

        if (!$user && $this->shouldAuthorize()) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        // Students can only see their own history
        if ($user && $user->role === 'student') {
            $filters['student_id'] = $user->id;
        }

        $history = $this->attendanceRepository->getHistory($filters);

        return response()->json($history);
    }

    protected function shouldAuthorize(): bool
    {
        return (bool) config('api.require_auth', false);
    }
}
