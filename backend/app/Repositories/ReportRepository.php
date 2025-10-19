<?php

namespace App\Repositories;

use App\Models\ClassRoom;
use Illuminate\Support\Facades\DB;

class ReportRepository
{
    public function getAttendanceSummary(array $filters)
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