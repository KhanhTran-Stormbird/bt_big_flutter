<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Api\V1\{
  AuthController, UsersController, ClassesController, SessionsController,
  AttendanceController, ReportsController, QrController
};
use App\Http\Controllers\Api\V1\FaceSamplesController;

Route::prefix('v1')->group(function () {
  // Auth
  Route::post('/auth/login', [AuthController::class, 'login'])->middleware('throttle:login');
  Route::post('/auth/refresh', [AuthController::class, 'refresh'])->middleware('throttle:login');

  $requireAuth = config('api.require_auth', false);
  $protectedMiddleware = $requireAuth ? ['auth:api'] : [];
  $manageUsersMiddleware = $requireAuth ? ['can:manage-users'] : [];
  $manageClassesMiddleware = $requireAuth ? ['can:manage-classes'] : [];
  $manageSessionsMiddleware = $requireAuth ? ['can:manage-sessions'] : [];

  Route::middleware($protectedMiddleware)->group(function () use (
    $manageUsersMiddleware,
    $manageClassesMiddleware,
    $manageSessionsMiddleware
  ) {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);

    // Users (Admin)
    Route::middleware($manageUsersMiddleware)->group(function () {
      Route::get('/users', [UsersController::class, 'index']);
      Route::post('/users', [UsersController::class, 'store']);
      Route::put('/users/{id}', [UsersController::class, 'update']);
      Route::delete('/users/{id}', [UsersController::class, 'destroy']);
    });

    // Classes
    Route::get('/classes', [ClassesController::class, 'index']);
    Route::get('/classes/{id}', [ClassesController::class, 'show']);
    Route::post('/classes', [ClassesController::class, 'store'])->middleware($manageClassesMiddleware);
    Route::put('/classes/{id}', [ClassesController::class, 'update'])->middleware($manageClassesMiddleware);
    Route::delete('/classes/{id}', [ClassesController::class, 'destroy'])->middleware($manageClassesMiddleware);
    Route::post('/classes/{id}/students/import', [ClassesController::class, 'importStudents'])
      ->middleware($manageClassesMiddleware);

    // Sessions
    Route::get('/classes/{id}/sessions', [SessionsController::class, 'listByClass']);
    Route::post('/classes/{id}/sessions', [SessionsController::class, 'store'])->middleware($manageSessionsMiddleware);
    Route::get('/sessions/{id}', [SessionsController::class, 'show']);
    Route::put('/sessions/{id}', [SessionsController::class, 'update'])->middleware($manageSessionsMiddleware);
    Route::post('/sessions/{id}/close', [SessionsController::class, 'close'])->middleware($manageSessionsMiddleware);
    Route::post('/sessions/{id}/open', [SessionsController::class, 'open'])->middleware($manageSessionsMiddleware);
    Route::delete('/sessions/{id}', [SessionsController::class, 'destroy'])->middleware($manageSessionsMiddleware);

    // QR
    Route::post('/sessions/{id}/qr', [QrController::class, 'issue'])
      ->middleware($manageSessionsMiddleware);
    Route::post('/attendance/scan-qr', [QrController::class, 'scan']);

    // Attendance
    Route::post('/attendance/check-in', [AttendanceController::class, 'checkIn']);
    Route::get('/attendance/history', [AttendanceController::class, 'history']);

    // Face samples (enroll & manage own face embeddings)
    Route::get('/face-samples', [FaceSamplesController::class, 'index']);
    Route::post('/face-samples', [FaceSamplesController::class, 'store']);
    Route::post('/face-samples/match', [FaceSamplesController::class, 'match']);
    Route::delete('/face-samples/{id}', [FaceSamplesController::class, 'destroy']);

    // Reports
    Route::get('/reports/attendance', [ReportsController::class, 'summary']);
    Route::get('/reports/attendance/xlsx', [ReportsController::class, 'exportExcel']);
    Route::get('/reports/attendance/pdf',  [ReportsController::class, 'exportPdf']);
  });
});
