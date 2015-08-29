#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

sudo aptitude update

debconf-set-selections <<< 'mysql-server mysql-server/root_password password secret'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password secret'

sudo aptitude install -y -f mysql-server mysql-client nginx php5-fpm

sudo aptitude install -y -f php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcached php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl php5-xcache

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

sudo rm /etc/nginx/sites-enabled/default
sudo touch /etc/nginx/sites-enabled/default
sudo cat >> /etc/nginx/sites-enabled/default <<'EOF'
include /etc/nginx/sites-available/adminer;
EOF

sudo service nginx restart

sudo service php5-fpm restart

sudo aptitude install -y -f git zsh
#sudo zsh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
