<?php

namespace App\Http\Controllers\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;

class UsersController extends Controller
{
    public function index()
    {
        return response()->json(['data' => []]);
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

