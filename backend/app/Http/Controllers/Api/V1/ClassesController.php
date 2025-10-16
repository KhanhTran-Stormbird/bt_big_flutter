<?php

namespace App\Http\Controllers\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use App\Models\ClassRoom;

class ClassesController extends Controller
{
    public function index()
    {
        $classes = ClassRoom::select('id', 'name', 'subject', 'term')->orderBy('id', 'desc')->get();
        return response()->json($classes);
    }

    public function show($id)
    {
        $c = ClassRoom::select('id', 'name', 'subject', 'term')->findOrFail((int) $id);
        return response()->json($c);
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
