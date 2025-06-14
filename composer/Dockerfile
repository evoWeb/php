FROM composer:latest

RUN apk --update --no-cache add rsync mysql-client mariadb-client; \
    docker-php-ext-install mysqli pgsql;

CMD ["composer"]
