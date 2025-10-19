<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

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

        $data['password'] = Hash::make($data['password']);

        $user = User::query()->create($data);

        return Response::json([
            'message' => 'User created successfully',
            'data'    => $user,
        ]);
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

        $user->update($data);

        return Response::json([
            'message' => 'User updated successfully',
            'data'    => $user,
        ]);
    }

    /**
     * Xoá người dùng.
     */
    public function destroy(int $id)
    {
        $user = User::query()->findOrFail($id);
        $user->delete();

        return Response::json(['message' => 'User deleted successfully']);
    }
}
