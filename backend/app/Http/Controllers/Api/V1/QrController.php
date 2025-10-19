<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\QrService;
use App\Repositories\SessionRepository;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Cache;

class QrController extends Controller
{
    protected QrService $qrService;
    protected SessionRepository $sessionRepository;

    public function __construct(QrService $qrService, SessionRepository $sessionRepository)
    {
        $this->qrService = $qrService;
        $this->sessionRepository = $sessionRepository;
    }

    public function issue(int $sessionId): JsonResponse
    {
        $session = $this->sessionRepository->findById($sessionId);
        if ($this->shouldAuthorize()) {
            $this->authorize('update', $session->classRoom);
        }

        // Open the session if it's scheduled
        if ($session->status === 'scheduled') {
            $session->update(['status' => 'open']);
        }

        if ($session->status !== 'open') {
            return response()->json(['message' => 'Session is not open for QR code generation.'], 400);
        }

        $qrData = $this->qrService->generateQrCode($session);

        return response()->json($qrData);
    }

    public function scan(Request $request): JsonResponse
    {
        $rules = ['qr_json' => 'required|json'];
        if (!$this->shouldAuthorize()) {
            $rules['student_id'] = 'nullable|integer|exists:users,id';
        }

        $data = $request->validate($rules);

        $sessionId = $this->qrService->verifyQrCode($data['qr_json']);

        if (!$sessionId) {
            return response()->json(['message' => 'Invalid or expired QR code.'], 400);
        }

        // The session is valid. Now, we need a way for the student to prove
        // they are who they say they are for the actual check-in.
        // We'll generate a short-lived, single-use token.
        $sessionToken = bin2hex(random_bytes(20));
        $cacheKey = "session_token:{$sessionToken}";
        $studentId = optional($request->user())->id;

        if (!$studentId) {
            if ($this->shouldAuthorize()) {
                return response()->json(['message' => 'Unauthenticated.'], 401);
            }

            $studentId = $data['student_id'] ?? config('api.default_user_id');
            if (!$studentId) {
                return response()->json(['message' => 'student_id is required when authentication is disabled.'], 400);
            }
        }

        // Cache the token with session and student ID for 5 minutes
        Cache::put($cacheKey, ['session_id' => $sessionId, 'student_id' => $studentId], 300);

        return response()->json(['session_token' => $sessionToken]);
    }

    protected function shouldAuthorize(): bool
    {
        return (bool) config('api.require_auth', false);
    }
}
