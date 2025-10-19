<?php

namespace App\Http\Controllers\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;

class SessionsController extends Controller
{
    public function listByClass($id)
    {
        return response()->json([
            [
                'id' => 1,
                'class_id' => (int) $id,
                'starts_at' => now()->subHour()->toDateTimeString(),
                'ends_at' => now()->addHours(1)->toDateTimeString(),
                'status' => 'open',
                'qr_ttl' => 15,
            ],
        ]);
    }

    public function store($id, Request $request)
    {
        return response()->json(['message' => 'Session created (stub)']);
    }

    public function show($id)
    {
        return response()->json(['data' => ['id' => (int) $id]]);
    }

    public function close($id)
    {
        return response()->json(['message' => 'Session closed (stub)']);
    }
}
