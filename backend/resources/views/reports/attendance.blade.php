<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Attendance Report</title>
    <style>
        body {
            font-family: sans-serif;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <h1>Attendance Report</h1>
    <table>
        <thead>
            <tr>
                <th>Class</th>
                <th>Student</th>
                <th>Attendance</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($summary as $item)
                <tr>
                    <td>{{ $item->class_name }}</td>
                    <td>{{ $item->student_name }}</td>
                    <td>
                        {{ $item->present_count }} / {{ $item->total_sessions }}
                        @if ($item->total_sessions > 0)
                            ({{ round(($item->present_count / $item->total_sessions) * 100, 2) }}%)
                        @endif
                    </td>
                </tr>
            @empty
                <tr>
                    <td colspan="3">No data available.</td>
                </tr>
            @endforelse
        </tbody>
    </table>
</body>
</html>
