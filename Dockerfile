FROM php:7.0-apache
MAINTAINER ablanco@siu.edu.ar

RUN echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y gnupg git mc nano vim subversion graphviz libpq-dev libpng-dev libmcrypt-dev libgmp-dev libxslt1-dev  \ 
    libldap2-dev wget libfreetype6-dev libjpeg62-turbo-dev \
    && docker-php-ext-install pdo_pgsql \
    && docker-php-ext-install gd \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    && docker-php-ext-install ldap \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-install xsl \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install exif \
    && docker-php-ext-install zip \
    && docker-php-ext-install pcntl \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/ \
    && docker-php-ext-install gmp \
    && apt-get -t jessie-backports install libsodium-dev libsodium18 \
    && apt-get remove -y libpq-dev libpng-dev libmcrypt-dev libgmp-dev libxslt1-dev libfreetype6-dev libjpeg62-turbo-dev \
    && rm -r /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

#Se agrega PHPUnit
RUN wget https://phar.phpunit.de/phpunit-5.7.27.phar && chmod +x phpunit-5.7.27.phar && mv phpunit-5.7.27.phar /usr/local/bin/phpunit

# Se instala nodejs, npm , bower y yarn
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb http://dl.yarnpkg.com/debian/ stable main" >> /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -y -qq nodejs yarn && npm install --global bower

RUN pecl install -f apcu
RUN pecl install -f libsodium-1.0.6
RUN printf "extension=apcu.so\napc.enabled=1\n" >> /usr/local/etc/php/conf.d/ext-apcu.ini
RUN printf "extension=libsodium.so\n" >> /usr/local/etc/php/conf.d/ext-libsodium.ini
RUN printf "date.timezone=America/Argentina/Buenos_Aires\n" >> /usr/local/etc/php/php.ini
RUN printf "log_errors=On\n" >> /usr/local/etc/php/php.ini

# Por defecto se utiliza la timezone de Buenos Aires
ENV TZ=America/Argentina/Buenos_Aires
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#Se pasa el access.log a archivo
RUN sed -i 's|/proc/self/fd/1|/var/log/apache2/access.log|' /etc/apache2/apache2.conf
#Se pasa el error.log a stdout, para que salga en el log de docker
RUN sed -i 's|/proc/self/fd/2|/proc/self/fd/1|' /etc/apache2/apache2.conf

#Define una variable para poder usar mc
RUN echo "export TERM=xterm" >> /root/.bashrc

COPY entrypoint.sh /
COPY localhost_template.ssl /etc/apache2/localhost_template.ssl
RUN chmod +x /entrypoint.sh
RUN mkdir /entrypoint.d

RUN a2enmod rewrite

EXPOSE 443

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["apache2-foreground"]


