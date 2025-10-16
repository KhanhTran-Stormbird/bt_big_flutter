<?php

return [
    // Provider: 'stub' for always-match testing, 'http' to call external AI API
    'provider' => env('FACE_PROVIDER', 'stub'),

    // Base URL for the external face API when provider = http
    'base_url' => rtrim((string) env('FACE_API_BASE', ''), '/'),

    // Endpoint paths
    'paths' => [
        'extract' => env('FACE_API_EXTRACT', '/extract'),
        'match' => env('FACE_API_MATCH', '/match'),
    ],

    // Match threshold (smaller distance = more similar). Example for cosine distance.
    'threshold' => (float) env('FACE_THRESHOLD', 0.6),

    // Request timeout (seconds) for provider=http
    'timeout' => (int) env('FACE_TIMEOUT', 10),
];

