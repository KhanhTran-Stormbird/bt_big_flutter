<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\FaceSample;
use App\Models\User;
use App\Services\FaceService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Throwable;

class FaceSamplesController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $this->resolveUser($request);

        if (!$user) {
            return $this->unauthenticatedResponse();
        }

        $samples = $user->faceSamples()->get(['id', 'path', 'quality_score', 'created_at']);

        return response()->json($samples);
    }

    public function store(Request $request, FaceService $face): JsonResponse
    {
        $request->validate([
            'image' => 'required|image|max:5120',
        ]);

        $user = $this->resolveUser($request);

        if (!$user) {
            return $this->unauthenticatedResponse();
        }

        try {
            $sample = $face->enroll($user, $request->file('image'));
        } catch (Throwable $exception) {
            report($exception);
            return response()->json(['message' => 'Unable to enroll face sample.'], 500);
        }

        return response()->json(
            $sample->only(['id', 'path', 'quality_score', 'created_at']),
            201
        );
    }

    public function match(Request $request, FaceService $face): JsonResponse
    {
        $request->validate([
            'image' => 'required|image|max:5120',
        ]);

        $user = $this->resolveUser($request);

        if (!$user) {
            return $this->unauthenticatedResponse();
        }

        if ($user->faceSamples()->count() === 0) {
            return response()->json(['message' => 'No enrolled samples found for this user.'], 404);
        }

        try {
            $result = $face->match($user, $request->file('image'));
        } catch (Throwable $exception) {
            report($exception);
            return response()->json(['matched' => false, 'message' => 'Face comparison failed.'], 500);
        }

        return response()->json($result);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $user = $this->resolveUser($request);

        if (!$user) {
            return $this->unauthenticatedResponse();
        }

        $sample = FaceSample::findOrFail($id);

        if ($sample->user_id !== $user->id) {
            return response()->json(['message' => 'You do not have permission to delete this sample.'], 403);
        }

        Storage::disk('faces')->delete($sample->path);
        $sample->delete();

        return response()->json(null, 204);
    }

    protected function shouldAuthorize(): bool
    {
        return (bool) config('api.require_auth', false);
    }

    protected function resolveUser(Request $request): ?User
    {
        $user = Auth::guard('api')->user();
        if ($user || $this->shouldAuthorize()) {
            return $user;
        }

        $userId = $request->input('user_id', config('api.default_user_id'));
        return $userId ? User::find($userId) : null;
    }

    protected function unauthenticatedResponse(): JsonResponse
    {
        if ($this->shouldAuthorize()) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        return response()->json(['message' => 'user_id is required when authentication is disabled.'], 400);
    }
}
