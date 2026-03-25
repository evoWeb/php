FROM composer:latest

RUN apk --update --no-cache add rsync mysql-client mariadb-client libpq-dev; \
    docker-php-ext-install mysqli pgsql;

CMD ["composer"]
