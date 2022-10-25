FROM php:8-fpm-alpine

RUN apk update \
    && apk add \
      imap-dev \
      libressl-dev \
      oniguruma-dev \
      php8-imap \
      php8-fileinfo \
      php8-iconv \
      php8-mbstring \
    && docker-php-ext-configure \
      imap --with-imap-ssl \
    && docker-php-ext-install \
      imap \
      fileinfo \
      iconv \
      mbstring \
    && docker-php-ext-enable \
      imap \
      fileinfo \
      iconv \
      mbstring

RUN echo '*/5	*	*	*	*	/etc/periodic/5min/forward.sh >/proc/1/fd/1 2>/proc/1/fd/2' >> /etc/crontabs/root \
    && crontab -l

WORKDIR /app

CMD ['crond', '-f', '-l', '2']
