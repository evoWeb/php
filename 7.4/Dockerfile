FROM php:7.4-fpm
USER root

RUN groupmod -g 82 www-data \
    && usermod -u 82 www-data

RUN apt-get update -y \
    && apt-get -y install \
    locales \
    mariadb-client \
    graphicsmagick \
    libfreetype6 \
    libfreetype6-dev \
    libicu-dev \
    libjpeg-dev \
    libpng-dev \
    libwebp-dev \
    libxml2 \
    libxml2-dev \
    unzip \
    libzip-dev \
    && docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-webp \
    && docker-php-ext-install gd intl mysqli pdo_mysql opcache soap zip \
    && apt-get remove -y \
        libfreetype6-dev \
        libjpeg-dev \
        libpng-dev \
        libwebp-dev \
        libxml2-dev \
        libzip-dev \
    && cp "${PHP_INI_DIR}/php.ini-production" "${PHP_INI_DIR}/php.ini" \
    && echo "de_DE.UTF-8 UTF-8\nen_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

WORKDIR /usr/local/apache2/htdocs
USER www-data
