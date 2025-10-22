<?php

namespace App\Repositories;

use App\Models\Attendance;
use App\Models\Session;
use App\Models\User;
use App\Services\FaceService;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use InvalidArgumentException;

class AttendanceRepository
{
    public function __construct(protected FaceService $faceService)
    {
    }

    /**
     * @throws \Exception
     */
    public function createFromQr(int $sessionId, int $studentId, UploadedFile $image): Attendance
    {
        $session = Session::findOrFail($sessionId);
        $student = User::findOrFail($studentId);

        if ($session->status !== 'open') {
            throw new InvalidArgumentException('Session is not open for attendance.');
        }

        $isEnrolled = $session->classRoom
            ->students()
            ->where('users.id', $student->id)
            ->exists();

        if (!$isEnrolled) {
            throw new InvalidArgumentException('Student is not enrolled in this class.');
        }

        $alreadyCheckedIn = $session->attendances()
            ->where('student_id', $student->id)
            ->exists();

        if ($alreadyCheckedIn) {
            throw new InvalidArgumentException('Attendance has already been recorded for this session.');
        }

        $faceResult = $this->faceService->match($student, $image);

        if (!$faceResult['matched']) {
            throw new InvalidArgumentException('Face verification failed.');
        }

        $disk = Storage::disk('checkins');
        $rootPath = $disk->path('');
        if (!is_dir($rootPath)) {
            mkdir($rootPath, 0755, true);
        }

        $directory = sprintf('sessions/%d/students/%d', $session->id, $student->id);
        $absoluteDirectory = $disk->path($directory);
        if (!is_dir($absoluteDirectory)) {
            if (!mkdir($absoluteDirectory, 0755, true) && !is_dir($absoluteDirectory)) {
                throw new \RuntimeException(sprintf('Unable to create directory %s', $absoluteDirectory));
            }
        }

        $imagePath = $image->store(
            $directory,
            'checkins'
        );

        try {
            $distance = $faceResult['distance'] ?? null;
            $attendance = DB::transaction(static function () use ($session, $student, $imagePath, $distance) {
                return Attendance::create([
                    'session_id' => $session->id,
                    'student_id' => $student->id,
                    'status' => 'present',
                    'method' => 'qr',
                    'checked_at' => now(),
                    'image_path' => $imagePath,
                    'distance' => $distance,
                ]);
            });
        } catch (\Throwable $throwable) {
            Storage::disk('checkins')->delete($imagePath);
            throw $throwable;
        }

        return $attendance->loadMissing(['student', 'session.classRoom']);
    }

    public function getHistory(array $filters)
    {
        $query = DB::table('attendances as a')
            ->join('class_sessions as cs', 'a.session_id', '=', 'cs.id')
            ->join('classes as c', 'cs.class_id', '=', 'c.id')
            ->select(
                'a.id',
                'a.session_id',
                'a.student_id',
                'a.status',
                'a.checked_at',
                'a.distance',
                'cs.starts_at as session_starts_at',
                'cs.ends_at as session_ends_at',
                'c.id as class_id',
                'c.name as class_name',
                'c.subject as class_subject'
            );

        if (isset($filters['class_id'])) {
            $query->where('cs.class_id', $filters['class_id']);
        }

        if (isset($filters['student_id'])) {
            $query->where('a.student_id', $filters['student_id']);
        }

        return $query->orderBy('a.checked_at', 'desc')->get();
    }
}
