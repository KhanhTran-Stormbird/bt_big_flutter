<?php

namespace App\Http\Controllers\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;

class ClassesController extends Controller
{
    public function index()
    {
        return response()->json([
            [
                'id' => 1,
                'name' => 'CS101 - Intro to CS',
                'subject' => 'Computer Science',
                'term' => '2025A',
            ],
        ]);
    }

    public function show($id)
    {
        return response()->json([
            'id' => (int) $id,
            'name' => 'Class #'.$id,
            'subject' => 'Subject',
            'term' => '2025A',
        ]);
    }

    public function store(Request $request)
    {
        return response()->json(['message' => 'Class created (stub)']);
    }

    public function update($id, Request $request)
    {
        return response()->json(['message' => 'Class updated (stub)']);
    }

    public function destroy($id)
    {
        return response()->json(['message' => 'Class deleted (stub)']);
    }

    public function importStudents($id, Request $request)
    {
        return response()->json(['message' => 'Students imported (stub)']);
    }
}
