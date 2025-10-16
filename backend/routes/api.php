<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Api\V1\{
  AuthController, UsersController, ClassesController, SessionsController,
  AttendanceController, ReportsController, QrController
};

Route::prefix('v1')->group(function () {
  // Auth
  Route::post('/auth/login', [AuthController::class, 'login'])->middleware('throttle:login');
  Route::post('/auth/refresh', [AuthController::class, 'refresh'])->middleware('throttle:login');

  $protectedMiddleware = env('DEV_AUTH_BYPASS', true) ? [] : ['auth:api'];
  Route::middleware($protectedMiddleware)->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);

    // Users (Admin)
    Route::middleware('can:manage-users')->group(function() {
      Route::get('/users', [UsersController::class, 'index']);
      Route::post('/users', [UsersController::class, 'store']);
      Route::put('/users/{id}', [UsersController::class, 'update']);
      Route::delete('/users/{id}', [UsersController::class, 'destroy']);
    });

    // Classes
    Route::get('/classes', [ClassesController::class, 'index']);
    Route::get('/classes/{id}', [ClassesController::class, 'show']);
    Route::post('/classes', [ClassesController::class, 'store'])->middleware('can:manage-classes');
    Route::put('/classes/{id}', [ClassesController::class, 'update'])->middleware('can:manage-classes');
    Route::delete('/classes/{id}', [ClassesController::class, 'destroy'])->middleware('can:manage-classes');
    Route::post('/classes/{id}/students/import', [ClassesController::class, 'importStudents'])
      ->middleware('can:manage-classes');

    // Sessions (buổi)
    Route::get('/classes/{id}/sessions', [SessionsController::class, 'listByClass']);
    Route::post('/classes/{id}/sessions', [SessionsController::class, 'store'])->middleware('can:manage-sessions');
    Route::get('/sessions/{id}', [SessionsController::class, 'show']);
    Route::post('/sessions/{id}/close', [SessionsController::class, 'close'])->middleware('can:manage-sessions');

    // QR
    Route::post('/sessions/{id}/qr', [QrController::class, 'issue'])      // trả SVG
      ->middleware('can:manage-sessions');
    Route::post('/attendance/scan-qr', [QrController::class, 'scan']);    // input: qr_json

    // Attendance
    Route::post('/attendance/check-in', [AttendanceController::class, 'checkIn']); // multipart image + session_token
    Route::get('/attendance/history', [AttendanceController::class, 'history']);

    // Reports
    Route::get('/reports/attendance', [ReportsController::class, 'summary']);
    Route::get('/reports/attendance/xlsx', [ReportsController::class, 'exportExcel']);
    Route::get('/reports/attendance/pdf',  [ReportsController::class, 'exportPdf']);
  });
});
