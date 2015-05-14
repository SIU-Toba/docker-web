FROM php:5.5-apache
RUN apt-get update && apt-get install -y libpq-dev libpng-dev \
    && docker-php-ext-install pdo_pgsql \
    && docker-php-ext-install gd

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
RUN mkdir /entrypoint.d

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["apache2-foreground"]


