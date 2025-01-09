FROM php:8.4-fpm

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    nginx \
    supervisor

# 安装 PHP 扩展
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# 安装 Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 设置工作目录
WORKDIR /var/www/html

# 复制项目文件
COPY . .

# 设置目录权限
RUN mkdir -p bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache

# 安装依赖
RUN composer install --no-interaction --no-dev --optimize-autoloader

# 创建日志目录
RUN mkdir -p /var/log/php \
    && mkdir -p /var/log/php-fpm \
    && chown -R www-data:www-data /var/log/php /var/log/php-fpm

# 配置 PHP 错误日志
RUN echo "error_log = /var/log/php/error.log" >> /usr/local/etc/php/php.ini \
    && echo "log_errors = On" >> /usr/local/etc/php/php.ini \
    && echo "error_reporting = E_ALL" >> /usr/local/etc/php/php.ini

# 配置 PHP-FPM 日志
RUN echo "[global]" > /usr/local/etc/php-fpm.d/zz-docker.conf \
    && echo "error_log = /var/log/php-fpm/error.log" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
    && echo "[www]" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
    && echo "access.log = /var/log/php-fpm/access.log" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
    && echo "access.format = {\"time\":\"%{%Y-%m-%dT%H:%M:%S%z}T\",\"client_ip\":\"%R\",\"remote_user\":\"%u\",\"request\":\"%m %{REQUEST_URI}e\",\"status\":\"%s\",\"body_bytes_sent\":\"%l\",\"request_time\":\"%d\",\"http_referrer\":\"%{HTTP_REFERER}e\",\"http_user_agent\":\"%{HTTP_USER_AGENT}e\",\"request_id\":\"%{HTTP_X_REQUEST_ID}e\",\"trace_id\":\"%{HTTP_X_AMZN_TRACE_ID}e\"}" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
    && echo "catch_workers_output = yes" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
    && echo "decorate_workers_output = no" >> /usr/local/etc/php-fpm.d/zz-docker.conf

# 配置 Nginx
COPY nginx.conf /etc/nginx/sites-available/default

# 配置 Supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 暴露端口
EXPOSE 80

# 复制启动脚本
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 设置启动命令
ENTRYPOINT ["docker-entrypoint.sh"] 