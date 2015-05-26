FROM php:5.5-apache
MAINTAINER ablanco@siu.edu.ar

RUN apt-get update && apt-get install -y libpq-dev libpng-dev \
    && docker-php-ext-install pdo_pgsql \
    && docker-php-ext-install gd \
    && rm -r /var/lib/apt/lists/*

RUN docker-php-ext-install mbstring

RUN apt-get update && apt-get install -y libmcrypt-dev \
    && docker-php-ext-install mcrypt \
    && rm -r /var/lib/apt/lists/*

RUN pecl install -f apcu
RUN printf "extension=apcu.so\napc.enabled=1\n" >> /usr/local/etc/php/conf.d/ext-apcu.ini
RUN printf "date.timezone=America/Argentina/Buenos_Aires\n" >> /usr/local/etc/php/php.ini
RUN printf "log_errors=On\n" >> /usr/local/etc/php/php.ini


COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
RUN mkdir /entrypoint.d

RUN a2enmod rewrite

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["apache2-foreground"]


