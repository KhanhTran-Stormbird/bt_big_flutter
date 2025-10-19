<?php

namespace App\Repositories;

use App\Models\Session;
use Illuminate\Support\Collection;
use InvalidArgumentException;

class SessionRepository
{
    private const STATUS_SCHEDULED = 'scheduled';
    private const STATUS_OPEN = 'open';
    private const STATUS_CLOSED = 'closed';

    private const VALID_STATUSES = [
        self::STATUS_SCHEDULED,
        self::STATUS_OPEN,
        self::STATUS_CLOSED,
    ];

    private const TRANSITIONS = [
        self::STATUS_SCHEDULED => [self::STATUS_OPEN],
        self::STATUS_OPEN => [self::STATUS_CLOSED],
        self::STATUS_CLOSED => [],
    ];

    public function findById(int $id): Session
    {
        return Session::findOrFail($id);
    }

    public function getByClassId(int $classId): Collection
    {
        return Session::where('class_id', $classId)
            ->orderByDesc('starts_at')
            ->get();
    }

    public function create(array $data): Session
    {
        $payload = array_merge([
            'status' => self::STATUS_SCHEDULED,
            'qr_ttl' => config('face.qr_ttl', 60),
        ], $data);
        $this->assertValidStatus($payload['status']);

        return Session::create($payload);
    }

    public function update(int $id, array $data): Session
    {
        $session = $this->findById($id);

        if (isset($data['status'])) {
            $this->assertValidStatus($data['status']);
            if ($data['status'] !== $session->status) {
                $this->assertValidTransition($session->status, $data['status']);
            }
        }

        $session->fill($data);
        $session->save();

        return $session->refresh();
    }

    public function delete(int $id): void
    {
        $session = $this->findById($id);

        if ($session->status !== self::STATUS_SCHEDULED) {
            throw new InvalidArgumentException('Only scheduled sessions can be deleted.');
        }

        $session->delete();
    }

    public function open(int $id): Session
    {
        return $this->transition($id, self::STATUS_OPEN);
    }

    public function close(int $id): Session
    {
        return $this->transition($id, self::STATUS_CLOSED);
    }

    protected function transition(int $id, string $targetStatus): Session
    {
        $session = $this->findById($id);
        $this->assertValidStatus($targetStatus);

        if ($targetStatus === $session->status) {
            return $session;
        }

        $this->assertValidTransition($session->status, $targetStatus);

        $session->update(['status' => $targetStatus]);

        return $session->refresh();
    }

    private function assertValidStatus(string $status): void
    {
        if (!in_array($status, self::VALID_STATUSES, true)) {
            throw new InvalidArgumentException("Invalid session status: {$status}");
        }
    }

    private function assertValidTransition(string $current, string $next): void
    {
        $allowed = self::TRANSITIONS[$current] ?? [];
        if (!in_array($next, $allowed, true)) {
            throw new InvalidArgumentException("Cannot transition session status from {$current} to {$next}.");
        }
    }
}
