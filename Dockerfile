FROM php:7.3-apache

WORKDIR /var/www/html
COPY . .

RUN apt-get update

# 1. development packages
RUN apt-get install -y \
    vim \
    nano \
    git \
    zip \
    curl \
    sudo \
    unzip \
    mariadb-client \
    libicu-dev \
    libbz2-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libmcrypt-dev \
    libreadline-dev \
    libfreetype6-dev \
    libc-client-dev \
    libkrb5-dev \
    zlib1g-dev \
    g++

RUN rm -r /var/lib/apt/lists/*

# 2. mod_rewrite for URL rewrite and mod_headers for .htaccess extra headers like Access-Control-Allow-Origin
RUN a2enmod rewrite headers

# 3. start with base php config, then add extensions
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl
RUN docker-php-ext-install \
    gd \
    bz2 \
    imap \
    exif \
    intl \
    iconv \
    bcmath \
    opcache \
    calendar \
    pdo_mysql \
    zip

# 4. composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 5. we need a user with the same UID/GID with host user
# so when we execute CLI commands, all the host file's ownership remains intact
# otherwise command from inside container will create root-owned files and directories
ARG uid
RUN useradd -G www-data,root -u $uid -d /home/devuser devuser
RUN mkdir -p /home/devuser/.composer && chown -R devuser:devuser /home/devuser

RUN chown -R www-data: common medias
RUN chmod -R 777 common medias

RUN ls -la
