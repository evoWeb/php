FROM debian:12-slim
USER root

ENV TZ="Europe/Berlin"
ENV LOCALE="de_DE.UTF-8 UTF-8\nen_US.UTF-8 UTF-8"
ENV PHPIZE_DEPS \
    wget \
    gnupg2 \
    lsb-release \
    libfreetype6-dev \
    libicu-dev \
    libjpeg-dev \
    libpng-dev \
    libwebp-dev \
    libxml2-dev \
    libzip-dev \
    locales

RUN set -eux; \
    apt-get update -y \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        $PHPIZE_DEPS \
        ca-certificates \
        catdoc \
        curl \
        exiftags \
        ghostscript \
        graphicsmagick \
        mariadb-client \
        libzip4 \
        libfreetype6 \
        libimage-exiftool-perl \
        libxml2 \
        poppler-utils \
        tzdata; \
    echo $TZ > /etc/timezone \
 && rm -f /etc/localtime \
 && dpkg-reconfigure -fnoninteractive tzdata \
 && echo $LOCALE > /etc/locale.gen \
 && locale-gen \
 && update-locale; \
    curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list; \
    apt-get update -y \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        php8.1 \
        php8.1-apcu \
        php8.1-bcmath \
        php8.1-bz2 \
        php8.1-cli \
        php8.1-common \
        php8.1-curl \
        php8.1-dev \
        php8.1-fpm \
        php8.1-gd \
        php8.1-imap \
        php8.1-intl \
        php8.1-mbstring \
        php8.1-mcrypt \
        php8.1-mysql \
        php8.1-opcache \
        php8.1-readline \
        php8.1-soap \
        php8.1-sqlite3 \
        php8.1-xml \
        php8.1-zip \
        php8.1-xdebug; \
    apt-get purge -y $PHPIZE_DEPS \
 && apt-get autoremove -y \
 && apt-get clean -y; \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
 && php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
 && php composer-setup.php --install-dir=/usr/bin --filename=composer \
 && php -r "unlink('composer-setup.php');"; \
    mkdir -p /usr/local/apache2/htdocs/ \
 && chgrp www-data /var/log \
 && chmod gu+w /var/log

COPY ./config/debug-custom.ini /etc/php/8.1/fpm/conf.d/z-custom.ini
COPY ./config/www.conf /etc/php/8.1/fpm/pool.d/www.conf

WORKDIR /usr/local/apache2/htdocs/
USER www-data
CMD ["php-fpm8.1"]
