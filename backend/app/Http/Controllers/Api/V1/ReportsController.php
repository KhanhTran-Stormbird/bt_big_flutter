<?php

namespace App\Http\Controllers\Api\V1;

use App\Exports\AttendanceExport;
use App\Http\Controllers\Controller;
use App\Repositories\ReportRepository;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Maatwebsite\Excel\Facades\Excel;

class ReportsController extends Controller
{
    protected ReportRepository $reportRepository;

    public function __construct(ReportRepository $reportRepository)
    {
        $this->reportRepository = $reportRepository;
        // $this->middleware('can:view-reports'); // Assumes a 'view-reports' policy exists
    }

    public function summary(Request $request): JsonResponse
    {
        $filters = $request->validate([
            'class_id' => 'sometimes|integer|exists:classes,id',
        ]);

        $summary = $this->reportRepository->getAttendanceSummary($filters);

        return response()->json(['data' => $summary]);
    }

    public function exportExcel(Request $request)
    {
        $filters = $request->validate([
            'class_id' => 'sometimes|integer|exists:classes,id',
        ]);

        $details = $this->reportRepository->getAttendanceDetails($filters);

        return Excel::download(new AttendanceExport($details), 'attendance_report.xlsx');
    }

    public function exportPdf(Request $request)
    {
        $filters = $request->validate([
            'class_id' => 'sometimes|integer|exists:classes,id',
        ]);

        $details = $this->reportRepository->getAttendanceDetails($filters);

        $pdf = Pdf::loadView('reports.attendance', ['summary' => $details]);

        return $pdf->download('attendance_report.pdf');
    }
}
