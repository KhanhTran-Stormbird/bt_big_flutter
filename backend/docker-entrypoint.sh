#!/usr/bin/env sh
set -e

umask 0002   # đảm bảo file sinh ra có group-writable (775/664)

echo "[entrypoint] Ensuring writable runtime directories"
mkdir -p /app/storage/logs \
  /app/storage/app/public \
  /app/storage/framework/cache \
  /app/storage/framework/sessions \
  /app/storage/framework/views \
  /app/bootstrap/cache

# fix quyền cho Laravel storage và bootstrap/cache
chown -R www-data:www-data /app/storage /app/bootstrap/cache || true
chmod -R ug+rwX /app/storage /app/bootstrap/cache || true

echo "[entrypoint] Installing PHP dependencies (composer install)"
# Chỉ chạy composer install nếu chưa có vendor
if [ ! -f vendor/autoload.php ]; then
  composer install --no-interaction --prefer-dist --ignore-platform-reqs --no-scripts || true
else
  echo "[entrypoint] Vendor already present, skipping composer install"
fi

# Sinh APP_KEY nếu chưa có
if [ -f .env ]; then
  APP_KEY_VALUE=$(grep ^APP_KEY= .env | cut -d= -f2)
  if [ -z "$APP_KEY_VALUE" ]; then
    echo "[entrypoint] Generating APP_KEY"
    php artisan key:generate --force || true
  fi
else
  echo "[entrypoint] WARNING: .env not found, skipping key generation"
fi

echo "[entrypoint] Caching Laravel config/routes/views"
php artisan storage:link || true
php artisan config:clear || true
php artisan config:cache || true
php artisan route:clear || true
php artisan route:cache || true
php artisan view:clear || true
php artisan view:cache || true

echo "[entrypoint] Waiting for database to be ready..."
# chờ MySQL hoạt động (dùng DB_HOST và DB_PORT)
MAX_RETRIES=30
COUNTER=0
until php -r "try { new PDO('mysql:host=' . getenv('DB_HOST') . ';port=' . getenv('DB_PORT') . ';dbname=' . getenv('DB_DATABASE'), getenv('DB_USERNAME'), getenv('DB_PASSWORD')); exit(0); } catch (Exception \$e) { exit(1); }"; do
  COUNTER=$((COUNTER+1))
  if [ "$COUNTER" -ge "$MAX_RETRIES" ]; then
    echo "[entrypoint] ERROR: Database not reachable after ${MAX_RETRIES} attempts"
    exit 1
  fi
  echo "[entrypoint] Waiting for MySQL... (${COUNTER}/${MAX_RETRIES})"
  sleep 3
done

echo "[entrypoint] Running database migrations / seed"
php artisan migrate --force || true
php artisan db:seed --force || true

echo "[entrypoint] Fixing ownership after artisan commands"
chown -R www-data:www-data /app/storage /app/bootstrap/cache || true
chmod -R ug+rwX /app/storage /app/bootstrap/cache || true

# Ép Nginx lắng nghe port 8080 thay vì 80
if [ -f /opt/docker/etc/nginx/vhost.common.d/00-listen.conf ]; then
  echo "listen 8080;" > /opt/docker/etc/nginx/vhost.common.d/00-listen.conf
fi

echo "[entrypoint] Starting supervisord (PHP-FPM + Nginx on port 8080)"
exec supervisord -n
