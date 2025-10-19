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

    public function store(Request $request)
    {
        return response()->json(['message' => 'User created (stub)']);
    }

    public function update($id, Request $request)
    {
        return response()->json(['message' => 'User updated (stub)']);
    }

    public function destroy($id)
    {
        return response()->json(['message' => 'User deleted (stub)']);
    }
}
