<?php

return [
    /*
    |--------------------------------------------------------------------------
    | API Authentication toggle
    |--------------------------------------------------------------------------
    |
    | When set to true, routes and controllers will enforce authentication and
    | authorization policies. When false, the API can be exercised without
    | requiring a bearer token (useful for local testing).
    |
    */
    'require_auth' => env('API_REQUIRE_AUTH', false),

    /*
    |--------------------------------------------------------------------------
    | Default user id when auth is disabled
    |--------------------------------------------------------------------------
    |
    | For local testing without authentication, controllers can use this ID to
    | resolve a user automatically instead of requiring it in every request.
    |
    */
    'default_user_id' => env('API_DEFAULT_USER_ID'),
];
