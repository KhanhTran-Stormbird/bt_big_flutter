<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Users\StoreUserRequest;
use App\Http\Requests\Users\UpdateUserRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Response;

class UsersController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = User::query();

        if ($request->filled('role')) {
            $rolesInput = $request->input('role');
            $roles = is_array($rolesInput) ? $rolesInput : [$rolesInput];
            $roles = collect($roles)
                ->map(fn ($role) => strtolower((string) $role))
                ->filter()
                ->unique();

            if ($roles->isNotEmpty()) {
                $query->whereIn('role', $roles);
            }
        }

        if ($request->filled('q')) {
            $term = '%' . trim($request->input('q')) . '%';
            $query->where(function ($builder) use ($term) {
                $builder
                    ->where('name', 'like', $term)
                    ->orWhere('email', 'like', $term);
            });
        }

        $users = $query
            ->orderBy('name')
            ->get(['id', 'name', 'email', 'role']);

        return response()->json(['data' => $users]);
    }

    /**
     * Tạo người dùng mới.
     */
    public function store(StoreUserRequest $request)
    {
        $data = $request->validated();

        $data['role'] = strtolower($data['role']);
        $data['password'] = Hash::make($data['password']);

        $user = User::query()->create($data);

        return Response::json([
            'message' => 'User created successfully',
            'data' => $user->only(['id', 'name', 'email', 'role']),
        ], 201);
    }

    /**
     * Cập nhật thông tin người dùng.
     */
    public function update(UpdateUserRequest $request, int $id)
    {
        $user = User::query()->findOrFail($id);

        $data = $request->validated();

        if (! $request->filled('password')) {
            unset($data['password']);
        } else {
            $data['password'] = Hash::make($data['password']);
        }

        if (isset($data['role'])) {
            $data['role'] = strtolower($data['role']);
        }

        $user->update($data);

        return Response::json([
            'message' => 'User updated successfully',
            'data' => $user->only(['id', 'name', 'email', 'role']),
        ]);
    }

    /**
     * Xoá người dùng.
     */
    public function destroy(int $id)
    {
        $user = User::query()->findOrFail($id);
        $user->delete();

        return Response::json(['message' => 'User deleted successfully'], 200);
    }
}
