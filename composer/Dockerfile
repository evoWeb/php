FROM composer:latest

RUN apk --update --no-cache add rsync mysql-client; \
    docker-php-ext-install mysqli

CMD ["composer"]
