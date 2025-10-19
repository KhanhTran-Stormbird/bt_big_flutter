<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Users\StoreUserRequest;
use App\Http\Requests\Users\UpdateUserRequest;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Response;
use App\Models\User;

class UsersController extends Controller
{
    /**
     * Hiển thị danh sách người dùng.
     */
    public function index()
    {
        $users = User::query()
            ->select(['id', 'name', 'email', 'role'])
            ->get();

        return Response::json(['data' => $users]);
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
