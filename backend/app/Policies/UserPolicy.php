<?php

namespace App\Policies;

use App\Models\User;

class UserPolicy
{
    public function viewAny(User $user)
    {
        return $user->role === 'admin';
    }

    public function create(User $user)
    {
        return $user->role === 'admin';
    }

    public function update(User $user, User $target)
    {
        return $user->role === 'admin' || $user->id === $target->id;
    }

    public function delete(User $user, User $target)
    {
        return $user->role === 'admin' && $user->id !== $target->id;
    }
}
