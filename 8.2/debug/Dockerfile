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
        php8.2 \
        php8.2-apcu \
        php8.2-bcmath \
        php8.2-bz2 \
        php8.2-cli \
        php8.2-common \
        php8.2-curl \
        php8.2-dev \
        php8.2-fpm \
        php8.2-gd \
        php8.2-imap \
        php8.2-intl \
        php8.2-mbstring \
        php8.2-mcrypt \
        php8.2-mysql \
        php8.2-opcache \
        php8.2-readline \
        php8.2-soap \
        php8.2-sqlite3 \
        php8.2-xml \
        php8.2-zip \
        php8.2-xdebug; \
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

COPY ./config/debug-custom.ini /etc/php/8.2/fpm/conf.d/z-custom.ini
COPY ./config/www.conf /etc/php/8.2/fpm/pool.d/www.conf

HEALTHCHECK --interval=60s --retries=5 --start-period=20s --timeout=10s \
    CMD curl --fail http://localhost:9000 || exit 1

WORKDIR /usr/local/apache2/htdocs/
USER www-data
CMD ["php-fpm8.2"]
