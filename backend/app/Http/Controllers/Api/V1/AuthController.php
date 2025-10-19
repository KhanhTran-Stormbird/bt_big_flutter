<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\ChangePasswordRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use function response;

class AuthController extends Controller
{
    public function login(LoginRequest $request): JsonResponse
    {
        $credentials = $request->validated();

        $user = User::where('email', $credentials['email'])->first();

        if (! $user || ! Hash::check($credentials['password'], $user->getAuthPassword())) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        $token = Auth::guard('api')->login($user);

        return $this->respondWithToken($token);
    }

    public function refresh(): JsonResponse
    {
        try {
            $new = Auth::guard('api')->refresh();
            return $this->respondWithToken($new);
        } catch (\Throwable $e) {
            return response()->json(['message' => 'Unable to refresh token'], 401);
        }
    }

    public function me(): JsonResponse
    {
        return response()->json(Auth::guard('api')->user());
    }

    public function logout(): JsonResponse
    {
        try {
            Auth::guard('api')->logout();
        } catch (\Throwable $e) {
            // ignore
        }

        return response()->json(['message' => 'Logged out']);
    }

    public function changePassword(ChangePasswordRequest $request): JsonResponse
    {
        $user = Auth::guard('api')->user();

        if (! $user) {
            return response()->json(['message' => 'Unauthenticated'], 401);
        }

        $data = $request->validated();

        if (! Hash::check($data['current_password'], $user->password)) {
            return response()->json(['message' => 'Current password is incorrect'], 422);
        }

        $user->forceFill([
            'password' => Hash::make($data['new_password']),
        ])->save();

        try {
            Auth::guard('api')->logout();
        } catch (\Throwable $e) {
            // ignore
        }

        $token = Auth::guard('api')->login($user);

        return $this->respondWithToken($token);
    }

    protected function respondWithToken(string $token): JsonResponse
    {
        $ttl = Auth::guard('api')->factory()->getTTL();

        return response()->json([
            'access_token' => $token,
            'token_type'   => 'bearer',
            'expires_in'   => $ttl * 60,
        ]);
    }
}
