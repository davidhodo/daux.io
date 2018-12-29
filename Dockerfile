FROM php:7.1-apache
MAINTAINER "David Hodo" <david.hodo@is4s.com>

EXPOSE 80

RUN apt-get update && apt-get -y install git unzip

# Download the daux.io archive on github
ADD http://github.com/dauxio/daux.io/archive/master.tar.gz /var/www/html/

# Untar the archive
WORKDIR /var/www/html
RUN \
  tar xvf master.tar.gz -C /var/www/html && \
  rm master.tar.gz && \
  cp -r daux.io-master/* daux.io-master/.htaccess /var/www/html/ && \
  rm -rf /var/www/html/daux.io-master && \
  rm -r /var/www/html/docs/* && \
  chgrp -R www-data /var/www/html && \
  chown -R www-data /var/www/html

# Install dependencies using composer: https://getcomposer.org/download/
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
 php -r "if (hash_file('sha384', 'composer-setup.php') === '93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
 php composer-setup.php && \
 php -r "unlink('composer-setup.php');" && \
 php composer.phar install

# Setup apache
RUN \
  a2enmod rewrite && \
  rm -rf /etc/apache2/sites-enabled/*

# Install apache config file and update script
COPY daux.io.conf /etc/apache2/sites-enabled/daux.io.conf
COPY update-webhook.php /var/www/html/
