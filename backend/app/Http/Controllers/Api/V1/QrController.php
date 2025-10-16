<?php

namespace App\Http\Controllers\Api\V1;

use Illuminate\Routing\Controller;

class QrController extends Controller
{
    public function issue($id)
    {
        return response()->json([
            'session_id' => (int) $id,
            'svg' => '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"></svg>',
            'ttl' => (int) config('jwt.ttl', 15),
        ]);
    }

    public function scan()
    {
        return response()->json(['session_token' => 'demo-session-token']);
    }
}
