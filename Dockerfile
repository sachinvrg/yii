# Use the official PHP 7.2 Apache image
FROM php:7.2-apache

# Enable Apache Rewrite module for Yii2 URL rules
RUN a2enmod rewrite

# Install required extensions and tools
RUN apt-get update && \
    apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
        unzip \
        && \
    docker-php-ext-install -j$(nproc) iconv gd zip pdo_mysql

# Set recommended PHP.ini settings
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN sed -i 's/^;date.timezone =$/date.timezone = "UTC"/' "$PHP_INI_DIR/php.ini"

# Create a directory for the Yii2 app and copy files
WORKDIR /var/www/html
COPY . .

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Yii2 dependencies
RUN composer install --prefer-dist --no-dev --no-scripts --no-progress --optimize-autoloader

# Set permissions for runtime directories
RUN chmod -R 777 runtime web/assets

# Expose port 80 for Apache
EXPOSE 80

# Start Apache server
CMD ["apache2-foreground"]
