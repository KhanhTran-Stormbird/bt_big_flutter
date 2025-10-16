<?php

return [
    'enabled' => env('ACTIVITYLOG_ENABLED', false),
    'default_log_name' => 'default',
    'database_connection' => env('ACTIVITYLOG_DB_CONNECTION'),
    'table_name' => env('ACTIVITYLOG_TABLE', 'activity_log'),
    'subject_returns_soft_deleted_models' => false,
    'causer_returns_soft_deleted_models' => false,
    'subject_authorization_exception' => false,
];
