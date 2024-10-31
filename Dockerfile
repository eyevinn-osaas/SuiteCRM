FROM php:8.2-apache-bullseye

RUN apt-get update && apt-get -y install wget unzip libzip-dev libicu-dev libxml2-dev libpng-dev

RUN docker-php-ext-install mysqli pdo pdo_mysql zip intl soap gd \
    && docker-php-ext-enable pdo_mysql zip intl soap gd 
RUN a2enmod rewrite

WORKDIR /source
VOLUME ["/var/www/html"]

RUN wget https://suitecrm.com/download/148/suite87/564544/suitecrm-8-7-0.zip
RUN unzip suitecrm-8-7-0.zip -d /var/www/html

RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html
RUN find /var/www/html -type d -not -perm 2755 -exec chmod 2755 {} \;
RUN find /var/www/html -type f -not -perm 0644 -exec chmod 0644 {} \;
RUN find /var/www/html ! -user www-data -exec chown www-data:www-data {} \;
RUN chmod +x /var/www/html/bin/console

ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!VirtualHost \*:80!VirtualHost \*:8080!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN sed -ri -e 's!Listen 80!Listen 8080!g' /etc/apache2/ports.conf

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN sed -ri -e 's!upload_max_filesize = 2M!upload_max_filesize = 20M!g' "$PHP_INI_DIR/php.ini"
RUN sed -ri -e 's!memory_limit = 128M!memory_limit = 256M!g' "$PHP_INI_DIR/php.ini"

ENTRYPOINT ["docker-php-entrypoint"]

CMD ["apache2-foreground"]