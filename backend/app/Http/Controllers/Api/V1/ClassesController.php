<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Repositories\ClassRepository;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\ClassRoom;

class ClassesController extends Controller
{
    protected ClassRepository $classRepository;

    public function __construct(ClassRepository $classRepository)
    {
        $this->classRepository = $classRepository;
    }

    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $filters = [];

        if ($user && $user->role === 'lecturer') {
            $filters['lecturer_id'] = $user->id;
        }

        $classes = $this->classRepository->getAll($filters);
        return response()->json($classes);
    }

    public function show(int $id): JsonResponse
    {
        $class = $this->classRepository->findById($id);
        if ($this->shouldAuthorize()) {
            $this->authorize('view', $class);
        }
        return response()->json($class);
    }

    public function store(Request $request): JsonResponse
    {
        if ($this->shouldAuthorize()) {
            $this->authorize('create', ClassRoom::class);
        }
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'subject' => 'required|string|max:255',
            'term' => 'required|string|max:255',
            'lecturer_id' => 'required|exists:users,id',
        ]);

        $class = $this->classRepository->create($data);
        return response()->json($class, 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $class = $this->classRepository->findById($id);
        if ($this->shouldAuthorize()) {
            $this->authorize('update', $class);
        }

        $data = $request->validate([
            'name' => 'sometimes|string|max:255',
            'subject' => 'sometimes|string|max:255',
            'term' => 'sometimes|string|max:255',
            'lecturer_id' => 'sometimes|exists:users,id',
        ]);

        $updatedClass = $this->classRepository->update($id, $data);
        return response()->json($updatedClass);
    }

    public function destroy(int $id): JsonResponse
    {
        $class = $this->classRepository->findById($id);
        if ($this->shouldAuthorize()) {
            $this->authorize('delete', $class);
        }
        $this->classRepository->delete($id);
        return response()->json(null, 204);
    }

    public function importStudents(Request $request, int $id): JsonResponse
    {
        $class = $this->classRepository->findById($id);
        if ($this->shouldAuthorize()) {
            $this->authorize('update', $class);
        }

        $request->validate([
            'file' => 'required|file|mimes:csv,txt',
        ]);

        $file = $request->file('file');
        // Using a simple approach without a dedicated import class for now
        $csvData = array_map('str_getcsv', file($file->getRealPath()));
        $header = array_shift($csvData);
        $emailColumn = array_search('email', array_map('strtolower', $header));

        if ($emailColumn === false) {
            return response()->json(['message' => 'CSV file must contain an "email" column.'], 422);
        }

        $studentsData = [];
        foreach ($csvData as $row) {
            if (isset($row[$emailColumn])) {
                $studentsData[] = ['email' => $row[$emailColumn]];
            }
        }

        $count = $this->classRepository->importStudents($id, $studentsData);

        return response()->json(['message' => "Successfully imported {$count} students."]);
    }

    protected function shouldAuthorize(): bool
    {
        return (bool) config('api.require_auth', false);
    }
}
