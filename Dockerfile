FROM php:7.3-fpm-alpine

# Install tools required for build stage
RUN apk add --update --no-cache \
    bash curl wget rsync ca-certificates openssl openssh git tzdata openntpd \
    libxrender fontconfig libc6-compat \
    mysql-client gnupg binutils-gold autoconf \
    g++ gcc gnupg libgcc linux-headers make python


# Install additional PHP libraries
RUN docker-php-ext-install mbstring mysqli pdo_mysql
RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql
RUN docker-php-ext-configure mbstring --enable-mbstring
RUN docker-php-ext-enable mysqli

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
 && chmod 755 /usr/local/bin/composer

# Install libraries for compiling GD, then build it
RUN apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev \
 && docker-php-ext-install gd \
 && apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

# Add ZIP archives support
RUN apk add --update --no-cache zlib-dev libzip-dev \
 && docker-php-ext-install zip

# Install xdebug
RUN pecl install xdebug \
 && docker-php-ext-enable xdebug

# Enable XDebug
ADD xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

RUN kill -USR2 1
WORKDIR /var/www
EXPOSE 9000