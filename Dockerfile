FROM php:8.2-apache-bullseye

RUN apt-get update && apt-get -y install wget unzip libzip-dev libicu-dev libxml2-dev libpng-dev

RUN docker-php-ext-install mysqli pdo pdo_mysql zip intl soap gd \
    && docker-php-ext-enable pdo_mysql zip intl soap gd 
RUN a2enmod rewrite

WORKDIR /source
VOLUME ["/var/www/html"]

RUN wget https://suitecrm.com/download/148/suite87/564544/suitecrm-8-7-0.zip

ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!VirtualHost \*:80!VirtualHost \*:8080!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN sed -ri -e 's!Listen 80!Listen 8080!g' /etc/apache2/ports.conf

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN sed -ri -e 's!upload_max_filesize = 2M!upload_max_filesize = 20M!g' "$PHP_INI_DIR/php.ini"
RUN sed -ri -e 's!memory_limit = 128M!memory_limit = 256M!g' "$PHP_INI_DIR/php.ini"

COPY osc-entrypoint.sh /usr/local/bin/osc-entrypoint.sh
RUN chmod +x /usr/local/bin/osc-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/osc-entrypoint.sh"]

CMD ["apache2-foreground"]