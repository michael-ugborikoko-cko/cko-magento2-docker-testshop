FROM php:7.2-apache

# CKO - Integration Dev Team
# Michael Ugborikoko

RUN apt-get update && apt-get install -y \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
	&& docker-php-ext-install -j$(nproc) iconv \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-install -j$(nproc) gd
#Install git
RUN apt-get install -y git
#Install php pdo and pdo_mysql
RUN docker-php-ext-install pdo pdo_mysql mysqli
RUN a2enmod rewrite
#Install php zip
RUN apt-get install -y sendmail libpng-dev
RUN apt-get install -y \
        zlib1g-dev 
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install zip
RUN apt-get install -y zlib1g-dev libicu-dev g++ \
&& docker-php-ext-configure intl \
&& docker-php-ext-install intl
RUN docker-php-ext-install bcmath \
&& apt-get install -y libxml2-dev && \
    docker-php-ext-install soap
RUN apt-get install -y libxslt-dev \
&& docker-php-ext-install xsl
#Install nano
RUN apt-get install nano -y
#Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=. --filename=composer
RUN mv composer /usr/local/bin/
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    apt-utils \
 && rm -rf /var/lib/apt/lists/*
COPY apache2/sites-available/ /etc/apache2/sites-available/
RUN a2ensite magento.conf
# increase php memory_limit
RUN sed -i -r 's/memory_limit = 128M/memory_limit = 2000M/' "$PHP_INI_DIR/php.ini-development"
# Use the default development configuration
RUN cp "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
# copy magento.repo credentials to server
COPY composer/ /root/.composer/
WORKDIR /var/www/html
RUN composer create-project --repository=https://repo.magento.com/ magento/project-community-edition app
RUN cp -r app/. /var/www/html/
RUN find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
RUN find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
RUN chown -R :www-data .
RUN chmod u+x bin/magento
COPY composer/. /var/www/html/
EXPOSE 80

