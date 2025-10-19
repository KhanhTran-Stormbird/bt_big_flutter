<?php

namespace App\Repositories;

use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class ReportRepository
{
    public function getAttendanceSummary(array $filters): array
    {
        $sessionQuery = DB::table('class_sessions as cs');
        if (!empty($filters['class_id'])) {
            $sessionQuery->where('cs.class_id', $filters['class_id']);
        }
        $totalSessions = (int) $sessionQuery->count();

        $attendanceQuery = DB::table('attendances as a')
            ->join('class_sessions as cs', 'a.session_id', '=', 'cs.id');

        if (!empty($filters['class_id'])) {
            $attendanceQuery->where('cs.class_id', $filters['class_id']);
        }

        $counts = $attendanceQuery->selectRaw("
                SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) as total_present,
                SUM(CASE WHEN a.status = 'absent' THEN 1 ELSE 0 END) as total_absent
            ")
            ->first();

        return [
            'total_sessions' => $totalSessions,
            'total_present' => (int) ($counts->total_present ?? 0),
            'total_absent' => (int) ($counts->total_absent ?? 0),
        ];
    }

    public function getAttendanceDetails(array $filters): Collection
    {
        $query = DB::table('attendances as a')
            ->join('users as u', 'a.student_id', '=', 'u.id')
            ->join('class_sessions as cs', 'a.session_id', '=', 'cs.id')
            ->join('classes as c', 'cs.class_id', '=', 'c.id')
            ->select(
                'c.id as class_id',
                'c.name as class_name',
                'u.id as student_id',
                'u.name as student_name',
                DB::raw('COUNT(a.id) as present_count'),
                DB::raw('(SELECT COUNT(*) FROM class_sessions WHERE class_id = c.id) as total_sessions')
            )
            ->where('a.status', 'present')
            ->groupBy('c.id', 'c.name', 'u.id', 'u.name');

        if (!empty($filters['class_id'])) {
            $query->where('c.id', $filters['class_id']);
        }

        return $query->get();
    }
}
