FROM ubuntu:jammy
USER root
ENV TZ="Europe/Berlin"
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
    libzip-dev

RUN set -eux; \
    apt-get update -y; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        $PHPIZE_DEPS \
        catdoc \
        curl \
        exiftags \
        ghostscript \
        graphicsmagick \
        mariadb-client \
        locales \
        libzip4 \
        libfreetype6 \
        libimage-exiftool-perl \
        libxml2 \
        poppler-utils \
        tzdata \
        ; \
    echo $TZ > /etc/timezone \
 && rm -f /etc/localtime \
 && dpkg-reconfigure -fnoninteractive tzdata \
 && locale-gen de_DE.UTF-8 \
 && locale-gen en_US.UTF-8 \
 && update-locale; \
    wget -O /etc/apt/keyrings/ondrej-php.asc http://keyserver.ubuntu.com/pks/lookup?op=get\&search=0x4F4EA0AAE5267A6C \
 && cat /etc/apt/keyrings/ondrej-php.asc \
 && echo "deb [signed-by=/etc/apt/keyrings/ondrej-php.asc] http://ppa.launchpad.net/ondrej/php/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list; \
    apt-get update -y \
 && apt-get install -y --no-install-recommends \
        php7.4 \
        php7.4-apcu \
        php7.4-bcmath \
        php7.4-bz2 \
        php7.4-cli \
        php7.4-common \
        php7.4-curl \
        php7.4-dev \
        php7.4-fpm \
        php7.4-gd \
        php7.4-imap \
        php7.4-intl \
        php7.4-json \
        php7.4-mbstring \
        php7.4-mysql \
        php7.4-opcache \
        php7.4-readline \
        php7.4-soap \
        php7.4-sqlite3 \
        php7.4-xml \
        php7.4-zip; \
    mkdir -p /usr/local/apache2/htdocs/; \
    php -r "copy('http://getcomposer.org/installer', 'composer-setup.php');" \
 && php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
 && php composer-setup.php --install-dir=/usr/bin --filename=composer \
 && php -r "unlink('composer-setup.php');"; \
    apt-get purge -y $PHPIZE_DEPS \
 && apt-get autoremove -y \
 && apt-get clean -y;

EXPOSE 9074
WORKDIR /usr/local/apache2/htdocs/
USER www-data
CMD ["php-fpm7.4"]
