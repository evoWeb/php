FROM php:7.4-fpm-bullseye
USER root

RUN groupmod -g 82 www-data; \
    usermod -u 82 www-data

RUN set -eux; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends \
        locales \
        mariadb-client \
        graphicsmagick \
        libfreetype6 \
        libicu-dev \
        libxml2 \
        libzip4 \
        libfreetype6-dev \
        libjpeg-dev \
        libpng-dev \
        libwebp-dev \
        libxml2-dev \
        libzip-dev \
    ; \
    docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-webp \
    ; \
    docker-php-ext-install gd \
        intl \
        mysqli \
        pdo_mysql \
        opcache \
        soap \
        zip \
    ; \
    apt-get purge -y \
        libfreetype6-dev \
        libjpeg-dev \
        libpng-dev \
        libwebp-dev \
        libxml2-dev \
        libzip-dev \
    ; \
    apt-get autoremove -y; \
    apt-get clean -y; \
    cp "${PHP_INI_DIR}/php.ini-production" "${PHP_INI_DIR}/php.ini"; \
    { \
        echo "de_DE.UTF-8 UTF-8"; \
        echo "en_US.UTF-8 UTF-8"; \
    } | tee /etc/locale.gen \
    && locale-gen; \
    sed -i "s/user = www-data/;user = www-data/" /usr/local/etc/php-fpm.d/www.conf.default; \
    sed -i "s/group = www-data/;group = www-data/" /usr/local/etc/php-fpm.d/www.conf.default; \
    sed -i "s/user = www-data/;user = www-data/" /usr/local/etc/php-fpm.d/www.conf; \
    sed -i "s/group = www-data/;group = www-data/" /usr/local/etc/php-fpm.d/www.conf

RUN set -eux; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends \
        wget \
        gnupg2 \
        lsb-release; \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg; \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list; \
    apt-get purge -y \
        wget \
        gnupg2 \
        lsb-release; \
    apt-get autoremove -y; \
    apt-get clean -y;

RUN apt-get update; \
    apt-get install -y \
        php-xdebug; \
    docker-php-ext-enable xdebug; \
    apt-get autoremove -y; \
    apt-get clean -y;

EXPOSE 9074
WORKDIR /usr/local/apache2/htdocs
USER www-data
