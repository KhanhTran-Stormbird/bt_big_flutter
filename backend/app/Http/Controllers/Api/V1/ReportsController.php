<?php

namespace App\Http\Controllers\Api\V1;

use Illuminate\Routing\Controller;

class ReportsController extends Controller
{
    public function summary()
    {
        return response()->json(['data' => []]);
    }

    public function exportExcel()
    {
        return response()->json(['message' => 'Export Excel (stub)']);
    }

    public function exportPdf()
    {
        return response()->json(['message' => 'Export PDF (stub)']);
    }
}
