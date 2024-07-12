FROM debian:bookworm-slim
USER root

ENV LOCALE="de_DE.UTF-8 UTF-8\nen_US.UTF-8 UTF-8"
ENV PHPIZE_DEPS="lsb-release ca-certificates locales"

RUN set -eux; \
    apt-get update -y \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ${PHPIZE_DEPS} \
        curl \
        cron; \
    dpkg-reconfigure -fnoninteractive tzdata \
 && echo $LOCALE > /etc/locale.gen \
 && locale-gen \
 && update-locale; \
    curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list; \
    apt-get update -y \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        php8.3 \
        php8.3-apcu \
        php8.3-cli \
        php8.3-common \
        php8.3-curl \
        php8.3-imap \
        php8.3-mbstring \
        php8.3-mcrypt; \
    apt-get purge -y ${PHPIZE_DEPS} \
 && apt-get autoremove -y \
 && apt-get clean -y; \
    mkdir -p /etc/cron.5minutes \
 && echo '*/5 *    * * *   root    cd / && run-parts --report /etc/cron.5minutes >/proc/1/fd/1 2>/proc/1/fd/2' >> /etc/crontab; \
    chgrp www-data /run; \
    chmod gu+rw /run; \
    chmod gu+s /usr/sbin/cron

WORKDIR /app
USER www-data
CMD ["/usr/sbin/cron", "-f", "-l", "2"]
