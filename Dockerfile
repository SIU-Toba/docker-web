FROM php:5.5-apache
MAINTAINER ablanco@siu.edu.ar

RUN apt-get update && apt-get install -y git mc nano subversion libpq-dev libpng-dev libmcrypt-dev libgmp-dev libxslt1-dev yui-compressor  \
    && docker-php-ext-install pdo_pgsql \
    && docker-php-ext-install gd \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-install xsl \
    && docker-php-ext-install mbstring \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/ \
    && docker-php-ext-install gmp \
    && apt-get remove -y libpq-dev libpng-dev libmcrypt-dev libgmp-dev libxslt1-dev \
    && rm -r /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

#Se agrega PHPUnit
RUN curl -OsS https://phar.phpunit.de/phpunit-old.phar && chmod +x phpunit-old.phar && mv phpunit-old.phar /usr/local/bin/phpunit

RUN pecl install -f apcu
RUN printf "extension=apcu.so\napc.enabled=1\n" >> /usr/local/etc/php/conf.d/ext-apcu.ini
RUN printf "date.timezone=America/Argentina/Buenos_Aires\n" >> /usr/local/etc/php/php.ini
RUN printf "log_errors=On\n" >> /usr/local/etc/php/php.ini

#Se pasa el access.log a archivo
RUN sed -i 's|/proc/self/fd/1|/var/log/apache2/access.log|' /etc/apache2/apache2.conf
#Se pasa el error.log a stdout, para que salga en el log de docker
RUN sed -i 's|/proc/self/fd/2|/proc/self/fd/1|' /etc/apache2/apache2.conf

#Define una variable para poder usar mc
RUN echo "export TERM=xterm" >> /root/.bashrc

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
RUN mkdir /entrypoint.d

RUN a2enmod rewrite

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["apache2-foreground"]


