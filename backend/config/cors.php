<?php

$frontendOrigins = array_filter(array_map('trim', explode(',', (string) env('FRONTEND_URLS', ''))));

if (empty($frontendOrigins)) {
    $singleOrigin = (string) env('FRONTEND_URL', '');
    if ($singleOrigin !== '') {
        $frontendOrigins = array_filter(array_map('trim', explode(',', $singleOrigin)));
    }
}

if (empty($frontendOrigins)) {
    $frontendOrigins = ['*'];
}

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['*'],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => ['Authorization'],
    'max_age' => 0,
    'supports_credentials' => (bool) env('CORS_SUPPORTS_CREDENTIALS', false),
];
