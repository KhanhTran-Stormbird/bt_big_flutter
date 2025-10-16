#!/usr/bin/env sh
set -e

echo "[entrypoint] Installing PHP dependencies (composer install)"
composer install --no-interaction --prefer-dist

if [ -z "$(grep ^APP_KEY= .env | cut -d= -f2)" ]; then
  echo "[entrypoint] Generating APP_KEY"
  php artisan key:generate --force || true
fi

echo "[entrypoint] Caching Laravel config/routes/views"
php artisan storage:link || true
php artisan config:clear || true
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

echo "[entrypoint] Running database migrations / seed"
php artisan migrate --force
php artisan db:seed --force || true

echo "[entrypoint] Starting supervisord"
exec supervisord -n

