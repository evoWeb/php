FROM debian:bookworm-slim
USER root

ARG ADDITIONAL_PACKAGES=""
ARG COMPOSER_FILE_HASH="dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6"
ARG TYPE="fpm"
ARG VERSION=8.3
ENV LOCALE="de_DE.UTF-8 UTF-8\nen_US.UTF-8 UTF-8"
ENV PHPIZE_DEPS="wget gnupg2 lsb-release libfreetype6-dev libicu-dev libpng-dev libjpeg-dev libtiff-dev libwebp-dev libavif-dev libheif-dev libxml2-dev libzip-dev locales"
ENV VERSION=${VERSION}

SHELL ["/bin/bash", "-c"]

RUN set -eux; \
    apt-get update -y \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ${PHPIZE_DEPS} \
        ca-certificates \
        catdoc \
        curl \
        libfcgi-bin \
        exiftags \
        ghostscript \
        imagemagick \
        mariadb-client \
        libzip4 \
        libfreetype6 \
        libimage-exiftool-perl \
        libxml2 \
        poppler-utils \
        tzdata; \
    dpkg-reconfigure -fnoninteractive tzdata \
 && echo $LOCALE > /etc/locale.gen \
 && locale-gen \
 && update-locale; \
    curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list; \
    apt-get update -y \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ${ADDITIONAL_PACKAGES} \
        php${VERSION} \
        php${VERSION}-apcu \
        php${VERSION}-bcmath \
        php${VERSION}-bz2 \
        php${VERSION}-cli \
        php${VERSION}-common \
        php${VERSION}-curl \
        php${VERSION}-dev \
        php${VERSION}-fpm \
        php${VERSION}-gd \
        php${VERSION}-imap \
        php${VERSION}-intl \
        php${VERSION}-mbstring \
        php${VERSION}-mcrypt \
        php${VERSION}-mysql \
        php${VERSION}-opcache \
        php${VERSION}-readline \
        php${VERSION}-soap \
        php${VERSION}-sqlite3 \
        php${VERSION}-xml \
        php${VERSION}-zip; \
    [ "${TYPE}" == "debug" ] && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends php${VERSION}-xdebug; \
    apt-get purge -y ${PHPIZE_DEPS} \
 && apt-get autoremove -y \
 && apt-get clean -y; \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
 && php -r "if (hash_file('sha384', 'composer-setup.php') === '${COMPOSER_FILE_HASH}') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
 && php composer-setup.php --install-dir=/usr/bin --filename=composer \
 && php -r "unlink('composer-setup.php');"; \
    mkdir -p /usr/local/apache2/htdocs/ \
 && chgrp www-data /var/log \
 && chmod gu+w /var/log

COPY ./config/${TYPE}-custom.ini /etc/php/${VERSION}/fpm/conf.d/z-custom.ini
COPY ./config/www.conf /etc/php/${VERSION}/fpm/pool.d/www.conf

HEALTHCHECK \
    --interval=60s \
    --retries=5 \
    --start-period=20s \
    --timeout=10s \
    CMD cgi-fcgi -bind -connect localhost:9000 || exit 1

WORKDIR /usr/local/apache2/htdocs/
USER www-data
CMD ["php-fpm8.2"]
