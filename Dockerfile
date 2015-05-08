FROM php:5.5-apache

RUN apt-get update && apt-get install -y libpq-dev libpng-dev \
    && docker-php-ext-install pdo_pgsql \
    && docker-php-ext-install gd 

RUN apt-get install -y libcurl3-dev \
    && docker-php-ext-install curl

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
RUN mkdir /entrypoint.d

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["apache2-foreground"]


