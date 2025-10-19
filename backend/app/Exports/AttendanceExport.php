<?php

namespace App\Exports;

use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;

class AttendanceExport implements FromCollection, WithHeadings, WithMapping
{
    protected $summary;

    public function __construct(Collection $summary)
    {
        $this->summary = $summary;
    }

    public function collection()
    {
        return $this->summary;
    }

    public function headings(): array
    {
        return [
            'Class ID',
            'Class Name',
            'Student ID',
            'Student Name',
            'Present Sessions',
            'Total Sessions',
            'Attendance Rate',
        ];
    }

    public function map($row): array
    {
        $attendanceRate = $row->total_sessions > 0
            ? round(($row->present_count / $row->total_sessions) * 100, 2) . '%'
            : 'N/A';

        return [
            $row->class_id,
            $row->class_name,
            $row->student_id,
            $row->student_name,
            $row->present_count,
            $row->total_sessions,
            $attendanceRate,
        ];
    }
}
