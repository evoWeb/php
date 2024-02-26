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

volumes:
    data:
        driver: local
        driver_opts:
            o: bind
            type: none
            device: ${INSTANCE_FOLDER:-.}/data/htdocs
    logs:
        driver: local
        driver_opts:
            o: bind
            type: none
            device: ${INSTANCE_FOLDER:-.}/data/logs

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
            - data:/usr/local/apache2/htdocs
            - logs:/var/log
            - '${INSTANCE_FOLDER:-.}/config/php/production.conf:/etc/php/8.3/fpm/pool.d/production.conf:ro'
            - '${INSTANCE_FOLDER:-.}/config/php/staging.conf:/etc/php/8.3/fpm/pool.d/staging.conf:ro'
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

## Usage of the composer image

The composer image is intended for usage as shell alias. It's extended with rsync and mysql-client to allow composer scripts to synchronize TYPO3 installations database and shared folder.

### .bashrc

The directories /etc/passwd and $HOME are mounted to tell the container what user $(id -u) is and allow ssh connections with ssh key.

This alias assumes that a docker network db exists. This is needed for the database synchronization.

AdditionalConfiguration.php is a file to override database connection information for Development context.
You need to implement the loading of AdditionalConfiguration.php in your TYPO3 installation.

The config around .config/composer and .cache/composer are used to allow installing composer global packages and store global authentications.

```shell
function composer() {
    mkdir -p $HOME/.config/composer
    mkdir -p $HOME/.cache/composer
    docker run -t \
        --user $(id -u):33 \
        --env COMPOSER_HOME=/config \
        --env COMPOSER_CACHE_DIR=/cache \
        --env SSH_AUTH_SOCK=/ssh-agent \
        --network db \
        --volume $(readlink -f $SSH_AUTH_SOCK):/ssh-agent \
        --volume /etc/passwd:/etc/passwd:ro \
        --volume $HOME/:$HOME/ \
        --volume $HOME/.config/composer:/config \
        --volume $HOME/.cache/composer:/cache \
        --volume $PWD:/app \
        --volume /home/www/AdditionalConfiguration.php:/AdditionalConfiguration.php \
        evoweb/php:composer $@
}

alias composer=composer
```

### composer.json

All _* scripts are configuration or internal command which should be called individually.

- _register:production:[host|port|path|container] are settings for the individual remote host.
- _sync_shared synchronizes the shared folder content from remote to local.
- _export_db exports the production database with the given TYPO3_CONTEXT with the help of helhum/typo3-console to the local folder ./shared/ with the current date (see $(date +%Y%m%d)) in the export file name.
- _import_db import the exported file of today (see $(date +%Y%m%d)) with the help of helhum/typo3-console
- _remove_db removes the export of today (see $(date +%Y%m%d)) after it was imported.

Script starting with typo3:* bundle call of configuration and internal command to achieve the sync, dump and import.

```json
{
    "scripts": {
        "_register:production:host": "@putenv HOST=[USER]@[HOST]",
        "_register:production:port": "@putenv PORT=[PORT]",
        "_register:production:path": "@putenv SSH_PATH=[PATH]",
        "_register:production:container": "@putenv INSTANCE_ID=[CONTAINER_ID]",

        "_register:production:context": [
            "@_register:production:host",
            "@_register:production:port",
            "@_register:production:path",
            "@_register:production:container",
            "@putenv TYPO3_CONTEXT=Production",
            "@putenv STAGE=production"
        ],
        "_register:local:context": [
            "@putenv TYPO3_CONTEXT=Development"
        ],

        "_sync_shared": "rsync -av -e \"ssh -p ${PORT}\" ${HOST}:${SSH_PATH}/* ./shared/",
        "_export_db": "ssh -p ${PORT} ${HOST} \"docker exec -e TYPO3_CONTEXT=\\\"${TYPO3_CONTEXT}\\\" \\$(docker ps -q -f name=${INSTANCE_ID}-app-1) php /usr/local/apache2/htdocs/${STAGE}/current/vendor/bin/typo3 database:export\" > ./shared/db_export_${STAGE}_$(date +%Y%m%d).sql",
        "_import_db": "typo3 database:import --connection Default < ./shared/db_export_${STAGE}_$(date +%Y%m%d).sql",
        "_remove_db": "rm ./shared/db_export_${STAGE}_$(date +%Y%m%d).sql",

        "typo3:sync:sharedproduction": [
            "@_register:production:context",
            "@_sync_shared"
        ],
        "typo3:sync:dbproduction": [
            "@typo3:dump:dbproduction",
            "@_register:local:context",
            "@_import_db",
            "@_remove_db"
        ],
        "typo3:dump:dbproduction": [
            "@_register:production:context",
            "@_export_db"
        ],
        "typo3:import:dbproduction": [
            "@_register:production:context",
            "@_register:local:context",
            "@_import_db"
        ]
    }
}
```
