<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Repositories\SessionRepository;
use App\Repositories\ClassRepository;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Carbon;
use InvalidArgumentException;

class SessionsController extends Controller
{
    protected SessionRepository $sessionRepository;
    protected ClassRepository $classRepository;

    public function __construct(SessionRepository $sessionRepository, ClassRepository $classRepository)
    {
        $this->sessionRepository = $sessionRepository;
        $this->classRepository = $classRepository;
    }

    public function listByClass(int $classId): JsonResponse
    {
        $class = $this->classRepository->findById($classId);
        if ($this->shouldAuthorize()) {
            $this->authorize('view', $class);
        }
        $sessions = $this->sessionRepository->getByClassId($classId);
        return response()->json($sessions);
    }

    public function show(int $id): JsonResponse
    {
        $session = $this->sessionRepository->findById($id);
        if ($this->shouldAuthorize()) {
            $this->authorize('view', $session->classRoom);
        }
        return response()->json($session);
    }

    public function store(Request $request, int $classId): JsonResponse
    {
        $class = $this->classRepository->findById($classId);
        if ($this->shouldAuthorize()) {
            $this->authorize('update', $class);
        }

        $data = $request->validate([
            'starts_at' => 'required|date',
            'ends_at' => 'required|date|after:starts_at',
        ]);

        $data['class_id'] = $classId;
        $session = $this->sessionRepository->create($data);
        return response()->json($session, 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $session = $this->sessionRepository->findById($id);
        if ($this->shouldAuthorize()) {
            $this->authorize('update', $session->classRoom);
        }

        $data = $request->validate([
            'starts_at' => 'sometimes|date',
            'ends_at' => 'sometimes|date',
            'status' => 'sometimes|in:scheduled,open,closed',
        ]);

        $proposedStarts = array_key_exists('starts_at', $data)
            ? Carbon::parse($data['starts_at'])
            : $session->starts_at;
        $proposedEnds = array_key_exists('ends_at', $data)
            ? Carbon::parse($data['ends_at'])
            : $session->ends_at;

        if ($proposedStarts && $proposedEnds && $proposedEnds->lessThanOrEqualTo($proposedStarts)) {
            return response()->json(['message' => 'The end time must be after the start time.'], 422);
        }

        try {
            $updatedSession = $this->sessionRepository->update($id, $data);
        } catch (InvalidArgumentException $exception) {
            return response()->json(['message' => $exception->getMessage()], 400);
        }

        return response()->json($updatedSession);
    }

    public function close(int $id): JsonResponse
    {
        $session = $this->sessionRepository->findById($id);
        if ($this->shouldAuthorize()) {
            $this->authorize('update', $session->classRoom);
        }

        try {
            $closedSession = $this->sessionRepository->close($id);
            return response()->json($closedSession);
        } catch (InvalidArgumentException $exception) {
            return response()->json(['message' => $exception->getMessage()], 400);
        }
    }

    public function open(int $id): JsonResponse
    {
        $session = $this->sessionRepository->findById($id);
        if ($this->shouldAuthorize()) {
            $this->authorize('update', $session->classRoom);
        }

        try {
            $openedSession = $this->sessionRepository->open($id);
            return response()->json($openedSession);
        } catch (InvalidArgumentException $exception) {
            return response()->json(['message' => $exception->getMessage()], 400);
        }
    }

    public function destroy(int $id): JsonResponse
    {
        $session = $this->sessionRepository->findById($id);
        if ($this->shouldAuthorize()) {
            $this->authorize('update', $session->classRoom);
        }

        try {
            $this->sessionRepository->delete($id);
        } catch (InvalidArgumentException $exception) {
            return response()->json(['message' => $exception->getMessage()], 400);
        }

        return response()->json(null, 204);
    }

    protected function shouldAuthorize(): bool
    {
        return (bool) config('api.require_auth', false);
    }
}
