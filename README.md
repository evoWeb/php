Test locally with https://github.com/nektos/act

## Test build locally
```shell
docker buildx build --load --no-cache --compress --progress plain --tag evoweb/php:8.3-fpm -f 8.3/fpm/Dockerfile .
```

## Usage

Either use docker directly like this
`docker run -d evoweb/php:8.3-fpm`
or use docker compose with a config file like in the example below.

Always use with at least one pool mounted. Either by overriding
`/etc/php/[7.4-8.3]/fpm/pool.d/www.conf`
or by adding pools like
`/etc/php/[7.4-8.3]/fpm/pool.d/production.conf`

### docker-compose.yml
```yaml
version: '3.9'

networks:
    backend: {}

services:
    app:
        image: evoweb/php:8.3-fpm
        container_name: ${APP_NAME}_app
        restart: always
        networks:
            - php
        environment:
            - HTTP_PRODUCTION_DOMAIN
            - HTTP_STAGING_DOMAIN
        volumes:
            - '/etc/localtime:/etc/localtime:ro'
            - '${INSTANCE_FOLDER:-.}/data/htdocs:/usr/local/apache2/htdocs'
            - '${INSTANCE_FOLDER:-.}/data/logs:/var/log'
            - '${INSTANCE_FOLDER:-.}/config/php/z-custom.ini:/etc/php/8.3/fpm/conf.d/z-custom.ini:ro'
            - '${INSTANCE_FOLDER:-.}/config/php/production.conf:/etc/php/8.3/fpm/pool.d/production.conf:ro'
            - '${INSTANCE_FOLDER:-.}/config/php/staging.conf:/etc/php/8.3/fpm/pool.d/staging.conf:ro'
        healthcheck:
            test: curl --fail http://localhost:9000 || exit 1
            interval: 60s
            retries: 5
            start_period: 20s
            timeout: 10s
```

### .env
```ini
INSTANCE_FOLDER=/srv/app
APP_NAME=app

HTTP_PRODUCTION_DOMAIN=www.app.de
HTTP_STAGING_DOMAIN=staging.app.de
```

### production.conf
```ini
[production]
listen = 9001

pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3

php_admin_value[error_log] = ${PHP_LOG_DIR}/${HTTP_PRODUCTION_DOMAIN}.production-php-error.log
```

### staging.conf
```ini
[staging]
listen = 9002

pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3

php_admin_value[error_log] = ${PHP_LOG_DIR}/${HTTP_STAGING_DOMAIN}.staging-php-error.log
```

## TYPO3 graphics related configuration
```php
$GLOBALS['TYPO3_CONF_VARS']['GFX'] = [
    'processor' => 'GraphicsMagick',
    'processor_allowTemporaryMasksAsPng' => false,
    'processor_colorspace' => 'RGB',
    'processor_effects' => true,
    'processor_enabled' => true,
    'processor_path' => '/usr/bin/',
]
```

## Default configuration in these images

### /etc/php/[7.4-8.3]/fpm/conf.d/z-custom.ini

These settings are fine for a default TYPO3 site with medium traffic.

```ini
max_input_vars = 1500
max_execution_time = 240
memory_limit = 256M
upload_max_filesize = 100M
post_max_size = 100M
log_errors = on
display_errors = off
```

### /etc/php/[7.4-8.3]/fpm/pool.d/www.conf

Global daemonize no is needed to keep the fpm process running in frontend or
else the container would stop immediately after start.

```ini
[global]
daemonize = no
[www]
listen = 9000
pm = ondemand
pm.max_children = 1
pm.max_requests = 5
```
