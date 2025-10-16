<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\FaceSample;
use App\Services\FaceService;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class FaceSamplesController extends Controller
{
    public function index()
    {
        $user = Auth::guard('api')->user();
        $samples = $user->faceSamples()->get(['id', 'path', 'quality_score', 'created_at']);
        return response()->json($samples);
    }

    public function store(Request $request, FaceService $face)
    {
        $request->validate([
            'image' => 'required|image|max:5120', // 5MB
        ]);
        $user = Auth::guard('api')->user();
        $path = $request->file('image')->store('users/'.$user->id, 'faces');
        $sample = $face->enroll($user, 'faces', $path);
        if (!$sample) {
            // remove stored file if enrollment failed
            Storage::disk('faces')->delete($path);
            return response()->json(['message' => 'Không thể trích xuất embedding khuôn mặt'], 422);
        }
        return response()->json($sample, 201);
    }

    public function destroy($id)
    {
        $user = Auth::guard('api')->user();
        $sample = FaceSample::findOrFail($id);
        if ($sample->user_id !== $user->id) {
            return response()->json(['message' => 'Không có quyền xoá mẫu này'], 403);
        }
        Storage::disk('faces')->delete($sample->path);
        $sample->delete();
        return response()->json(['message' => 'Đã xoá mẫu'], 200);
    }
}

