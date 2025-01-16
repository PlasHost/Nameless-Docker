# Base image for Nginx
FROM namelessmc/nginx:v2.1 AS nginx

# Copy data for Nginx
WORKDIR /data
COPY ./web /data

# Base image for PHP
FROM namelessmc/php:v2.1 AS php

# Copy data for PHP
WORKDIR /data
COPY ./web /data

# Base image for MariaDB
FROM mariadb:10.11 AS db

# Copy database data
WORKDIR /var/lib/mysql
COPY ./db /var/lib/mysql

# Combine all layers in the final image
FROM nginx

# Copy Nginx, PHP, and DB layers into the final image
COPY --from=php /data /data
COPY --from=db /var/lib/mysql /var/lib/mysql

# Expose ports
EXPOSE 8080

# Start all services (not recommended; better to use orchestration tools)
CMD service mysql start && \
    php-fpm && \
    nginx -g 'daemon off;'
