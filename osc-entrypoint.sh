#!/bin/sh

if [ ! -f /var/www/html/VERSION ]; then
  echo "SuiteCRM not found in /var/www/html - downloading software now..."
  unzip /source/suitecrm-8-7-0.zip -d /var/www/html

  chown -R www-data:www-data /var/www/html
  chmod -R 755 /var/www/html
  find /var/www/html -type d -not -perm 2755 -exec chmod 2755 {} \;
  find /var/www/html -type f -not -perm 0644 -exec chmod 0644 {} \;
  find /var/www/html ! -user www-data -exec chown www-data:www-data {} \;
  chmod +x /var/www/html/bin/console
fi

docker-php-entrypoint "$@"