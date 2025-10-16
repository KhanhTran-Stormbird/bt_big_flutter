FROM webdevops/php-nginx:8.3

# Reasonable PHP/Nginx defaults; can still be overridden via compose env
ENV WEB_DOCUMENT_ROOT=/app/public \
    PHP_OPCACHE_ENABLE=1 \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS=1 \
    PHP_OPCACHE_REVALIDATE_FREQ=2 \
    PHP_OPCACHE_MAX_ACCELERATED_FILES=20000 \
    PHP_OPCACHE_MEMORY_CONSUMPTION=192 \
    PHP_XDEBUG_MODE=off \
    PHP_FPM_PM_MAX_CHILDREN=10

WORKDIR /app

# Lightweight entrypoint to bootstrap Laravel then keep services in foreground
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

CMD ["/usr/local/bin/docker-entrypoint.sh"]

