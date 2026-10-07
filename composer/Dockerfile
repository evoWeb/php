FROM composer:latest

RUN apk add \
    --update \
    --no-cache \
    rsync \
    mysql-client \
    mariadb-client \
    libpq-dev; \
    docker-php-ext-install mysqli pgsql;

CMD ["composer"]
