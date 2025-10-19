<?php

namespace App\Policies;

use App\Models\Session;
use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class SessionPolicy
{
    use HandlesAuthorization;

    // Users can interact with sessions if they can interact with the parent class.

    public function view(User $user, Session $session): bool
    {
        return $user->can('view', $session->classRoom);
    }

    public function create(User $user, Session $session): bool
    {
        return $user->can('update', $session->classRoom);
    }

    public function update(User $user, Session $session): bool
    {
        return $user->can('update', $session->classRoom);
    }

    public function delete(User $user, Session $session): bool
    {
        return $user->can('update', $session->classRoom);
    }
}