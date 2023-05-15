FROM php:8-fpm-alpine

RUN apk update \
    && apk add \
      imap-dev \
      libressl-dev \
      oniguruma-dev \
    && docker-php-ext-configure \
      imap --with-imap-ssl \
    && docker-php-ext-install \
      imap \
    && docker-php-ext-enable \
      imap

RUN echo '*/5	*	*	*	*	/etc/periodic/5min/forward.sh >/proc/1/fd/1 2>/proc/1/fd/2' >> /etc/crontabs/root \
    && crontab -l

WORKDIR /app

CMD ["crond", "-f", "-l", "2"]
