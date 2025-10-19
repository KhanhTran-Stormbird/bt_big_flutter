<?php

use App\Http\Controllers\Api\V1\{
    AuthController,
    UsersController,
    ClassesController,
    SessionsController,
    AttendanceController,
    ReportsController,
    QrController
};
use App\Http\Controllers\Api\V1\FaceSamplesController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function (): void {
    Route::post('/auth/login', [AuthController::class, 'login'])->middleware('throttle:login');
    Route::post('/auth/refresh', [AuthController::class, 'refresh'])->middleware('throttle:login');

    $authMiddleware = config('auth.dev_auth_bypass') ? [] : ['auth:api'];

    Route::middleware($authMiddleware)->group(function (): void {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/auth/logout', [AuthController::class, 'logout']);
        Route::post('/auth/change-password', [AuthController::class, 'changePassword']);

        Route::middleware('can:manage-users')->group(function (): void {
            Route::get('/users', [UsersController::class, 'index']);
            Route::post('/users', [UsersController::class, 'store']);
            Route::match(['put', 'patch'], '/users/{id}', [UsersController::class, 'update']);
            Route::delete('/users/{id}', [UsersController::class, 'destroy']);
        });

        Route::get('/classes', [ClassesController::class, 'index']);
        Route::get('/classes/{id}', [ClassesController::class, 'show']);
        Route::post('/classes', [ClassesController::class, 'store'])->middleware('can:manage-classes');
        Route::put('/classes/{id}', [ClassesController::class, 'update'])->middleware('can:manage-classes');
        Route::delete('/classes/{id}', [ClassesController::class, 'destroy'])->middleware('can:manage-classes');
        Route::post('/classes/{id}/students/import', [ClassesController::class, 'importStudents'])
            ->middleware('can:manage-classes');

        Route::get('/classes/{id}/sessions', [SessionsController::class, 'listByClass']);
        Route::post('/classes/{id}/sessions', [SessionsController::class, 'store'])->middleware('can:manage-sessions');
        Route::get('/sessions/{id}', [SessionsController::class, 'show']);
        Route::post('/sessions/{id}/close', [SessionsController::class, 'close'])->middleware('can:manage-sessions');

        Route::post('/sessions/{id}/qr', [QrController::class, 'issue'])
            ->middleware('can:manage-sessions');
        Route::post('/attendance/scan-qr', [QrController::class, 'scan']);

        Route::post('/attendance/check-in', [AttendanceController::class, 'checkIn']);
        Route::get('/attendance/history', [AttendanceController::class, 'history']);

        Route::get('/face-samples', [FaceSamplesController::class, 'index']);
        Route::post('/face-samples', [FaceSamplesController::class, 'store']);
        Route::delete('/face-samples/{id}', [FaceSamplesController::class, 'destroy']);

        Route::get('/reports/attendance', [ReportsController::class, 'summary']);
        Route::get('/reports/attendance/xlsx', [ReportsController::class, 'exportExcel']);
        Route::get('/reports/attendance/pdf', [ReportsController::class, 'exportPdf']);
    });
});
