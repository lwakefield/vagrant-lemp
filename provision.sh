#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

sudo aptitude update

debconf-set-selections <<< 'mysql-server mysql-server/root_password password secret'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password secret'

sudo aptitude install -y -f mysql-server mysql-client nginx php5-fpm

sudo aptitude install -y -f php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcached php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl php5-xcache

sudo aptitude install -y -f git zsh supervisor unzip

#Set up adminer
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

sudo adduser --disabled-login --gecos 'git' git
sudo adduser git sudo
sudo wget http://gogs.dn.qbox.me/gogs_v0.6.5_linux_amd64.zip -O /var/www/gogs.zip
cd /var/www/
unzip gogs.zip
chmod a+x /var/www/gogs/gogs
mkdir -p /var/repos
mkdir -p /var/log/gogs
sudo cat >> /etc/supervisor/supervisord.conf <<'EOF'
[program:gogs]
directory=/var/www/gogs/
command=/var/www/gogs/gogs web
autostart=true
autorestart=true
startsecs=10
stdout_logfile=/var/log/gogs/stdout.log
stdout_logfile_maxbytes=1MB
stdout_logfile_backups=10
stdout_capture_maxbytes=1MB
stderr_logfile=/var/log/gogs/stderr.log
stderr_logfile_maxbytes=1MB
stderr_logfile_backups=10
stderr_capture_maxbytes=1MB
user = git
environment = HOME="/home/git", USER="git"#
EOF
sudo chown -R git /var/www/gogs
sudo chown -R git /var/repos
sudo chown -R git /var/log/gogs
sudo service supervisor restart

sudo rm /etc/nginx/sites-enabled/default
sudo touch /etc/nginx/sites-enabled/default
sudo cat >> /etc/nginx/sites-enabled/default <<'EOF'
include /etc/nginx/sites-available/adminer;
EOF

sudo service nginx restart
sudo service php5-fpm restart
