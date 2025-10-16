<?php

namespace App\Http\Controllers\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        if (!$token = Auth::guard('api')->attempt($credentials)) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        return $this->respondWithToken($token);
    }

    public function refresh(Request $request)
    {
        try {
            $new = Auth::guard('api')->refresh();
            return $this->respondWithToken($new);
        } catch (\Throwable $e) {
            return response()->json(['message' => 'Unable to refresh token'], 401);
        }
    }

    public function me(Request $request)
    {
        return response()->json(Auth::guard('api')->user());
    }

    public function logout(Request $request)
    {
        try {
            Auth::guard('api')->logout();
        } catch (\Throwable $e) {
            // ignore
        }
        return response()->json(['message' => 'Logged out']);
    }

    protected function respondWithToken(string $token)
    {
        $ttl = Auth::guard('api')->factory()->getTTL();
        return response()->json([
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => $ttl * 60,
        ]);
    }
}
