<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Custom rate limiter for auth endpoints
        RateLimiter::for('login', function (Request $request) {
            return [
                Limit::perMinute(10)->by($request->ip()),
            ];
        });

        // Simple ability gates based on user role
        Gate::define('manage-users', fn ($user) => in_array($user->role, ['admin']));
        Gate::define('manage-classes', fn ($user) => in_array($user->role, ['lecturer', 'admin']));
        Gate::define('manage-sessions', fn ($user) => in_array($user->role, ['lecturer', 'admin']));
    }
}
