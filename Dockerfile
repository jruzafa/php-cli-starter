FROM php:8.2.11-cli

MAINTAINER Jose Ruzafa Sierra <jose.ruzafa@gmail.com>

## Reconfigure timezones
ENV TZ=Europe/Madrid
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

RUN apt-get update && apt-get install -y \
        git \
        zip \
        unzip

## Install Xdebug
RUN echo "Install xdebug by pecl"
RUN yes | pecl install xdebug-3.2.0 \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.mode=debug\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.idekey=PHPSTORM\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_port=9000\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.discover_client_host=0\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Change TimeZone
RUN echo "Europe/Madrid" > /etc/timezone

#TOOLS
# Install composer globally
RUN echo "Install composer globally"
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

# RUN composer --no-interaction global require 'hirak/prestissimo'

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY src/ /var/www
COPY vendor/ /var/www

WORKDIR /var/www

CMD ['composer install']
