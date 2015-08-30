#!/bin/sh

sudo mkdir -p /var/www/adminer/
sudo wget http://www.adminer.org/latest-en.php -O /var/www/adminer/index.php
sudo touch /etc/nginx/sites-available/adminer
sudo cat >> /etc/nginx/sites-available/adminer <<'EOF'
server {

    listen   80;
    root /var/www/adminer;
    index index.php index.html index.htm;
    server_name adminer.dev;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

}
EOF
