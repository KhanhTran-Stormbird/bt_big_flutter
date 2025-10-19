<?php

namespace App\Policies;

use App\Models\ClassRoom;
use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class ClassPolicy
{
    use HandlesAuthorization;

    public function view(User $user, ClassRoom $classRoom): bool
    {
        if ($user->role === 'admin') {
            return true;
        }
        if ($user->role === 'lecturer') {
            return $classRoom->lecturer_id === $user->id;
        }
        if ($user->role === 'student') {
            return $classRoom->students->contains($user);
        }
        return false;
    }

    public function create(User $user): bool
    {
        return $user->role === 'admin';
    }

    public function update(User $user, ClassRoom $classRoom): bool
    {
        return $user->role === 'admin' || ($user->role === 'lecturer' && $classRoom->lecturer_id === $user->id);
    }

    public function delete(User $user, ClassRoom $classRoom): bool
    {
        return $user->role === 'admin';
    }
}