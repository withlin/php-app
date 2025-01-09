#!/bin/bash
set -e

# 创建日志符号链接到 stdout 和 stderr
ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log
ln -sf /dev/stderr /var/log/php/error.log
ln -sf /dev/stderr /var/log/php-fpm/error.log
ln -sf /dev/stdout /var/log/php-fpm/access.log
ln -sf /dev/stdout /var/www/html/storage/logs/laravel.log

# 确保日志目录和 socket 目录存在
mkdir -p /var/log/php /var/log/php-fpm /var/log/nginx /var/log/supervisor /run/php-fpm /var/www/html/storage/logs
chown -R www-data:www-data /run/php-fpm /var/www/html/storage

# 如果 APP_KEY 不存在，则生成一个新的
if [ -z "$APP_KEY" ]; then
    APP_KEY=$(php artisan key:generate --show)
    echo "Generated new APP_KEY: $APP_KEY"
fi

# 配置 PHP 错误日志
cat > /usr/local/etc/php/php.ini << EOF
error_log = /var/log/php/error.log
log_errors = On
error_reporting = E_ALL
EOF

# 配置 PHP-FPM
cat > /usr/local/etc/php-fpm.d/www.conf << EOF
[www]
user = www-data
group = www-data
listen = /run/php-fpm/php-fpm.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0660
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
access.log = /var/log/php-fpm/access.log
access.format = {"time":"%{%Y-%m-%dT%H:%M:%S%z}T","client_ip":"%R","remote_user":"%u","request":"%m %{REQUEST_URI}e","status":"%s","body_bytes_sent":"%l","request_time":"%d","http_referrer":"%{HTTP_REFERER}e","http_user_agent":"%{HTTP_USER_AGENT}e","request_id":"%{HTTP_X_REQUEST_ID}e"}
catch_workers_output = yes
decorate_workers_output = no
EOF

cat > /usr/local/etc/php-fpm.d/zz-docker.conf << EOF
[global]
error_log = /var/log/php-fpm/error.log
EOF

# 启动 supervisor
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf 