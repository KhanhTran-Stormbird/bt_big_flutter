<?php

return [
    // Your application's secret key used to sign the tokens
    'secret' => env('JWT_SECRET'),

    // Asymmetric keys for RS* / ES* (optional)
    'keys' => [
        'public' => env('JWT_PUBLIC_KEY'),
        'private' => env('JWT_PRIVATE_KEY'),
        'passphrase' => env('JWT_PASSPHRASE')
    ],

    // Token TTL (minutes)
    'ttl' => (int) env('JWT_TTL', 60),

    // Refresh TTL (minutes)
    'refresh_ttl' => (int) env('JWT_REFRESH_TTL', 20160),

    // Signing algorithm
    'algo' => env('JWT_ALGO', 'HS256'),

    // Required claims present on the token
    'required_claims' => ['iss', 'iat', 'exp', 'nbf', 'sub', 'jti'],

    // Enable token blacklisting (required for logout/invalidate)
    'blacklist_enabled' => env('JWT_BLACKLIST_ENABLED', true),

    // Grace period in seconds to account for clock skew
    'blacklist_grace_period' => (int) env('JWT_BLACKLIST_GRACE_PERIOD', 0),

    // Decrypt cookies - not used
    'decrypt_cookies' => false,

    // Providers
    'providers' => [
        'jwt' => Tymon\JWTAuth\Providers\JWT\Lcobucci::class,
        'auth' => Tymon\JWTAuth\Providers\Auth\Illuminate::class,
        'storage' => Tymon\JWTAuth\Providers\Storage\Illuminate::class,
    ],
];
