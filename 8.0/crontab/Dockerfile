FROM ubuntu:jammy
USER root
ENV TZ="Europe/Berlin"

RUN set -eux; \
    apt-get update -y \
 && apt-get install -y --no-install-recommends \
        lsb-release \
        ca-certificates \
        cron \
        curl; \
    curl -sSLo /etc/apt/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg \
 && echo "deb [signed-by=/etc/apt/keyrings/deb.sury.org-php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
 && echo "deb-src [signed-by=/etc/apt/keyrings/deb.sury.org-php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu $(lsb_release -sc) main" >> /etc/apt/sources.list.d/php.list \
 && cat /etc/apt/sources.list.d/php.list; \
    apt-get update -y \
 && apt-get install -y --no-install-recommends \
        php8.0 \
        php8.0-apcu \
        php8.0-cli \
        php8.0-common \
        php8.0-curl \
        php8.0-imap \
        php8.0-mbstring \
        php8.0-mcrypt \
 && apt-get autoremove -y \
 && apt-get clean -y; \
    mkdir -p /etc/cron.5minutes \
 && echo '*/5 *    * * *   root    cd / && run-parts --report /etc/cron.5minutes >/proc/1/fd/1 2>/proc/1/fd/2' >> /etc/crontab \
 && chgrp www-data /run \
 && chmod gu+rw /run \
 && chmod gu+s /usr/sbin/cron

WORKDIR /app
USER www-data
CMD ["/usr/sbin/cron", "-f", "-l", "2"]
