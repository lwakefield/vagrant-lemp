#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

sudo aptitude update

debconf-set-selections <<< 'mysql-server mysql-server/root_password password secret'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password secret'

sudo aptitude install -y -f mysql-server mysql-client nginx php5-fpm

sudo aptitude install -y -f php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcached php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl php5-xcache

sudo aptitude install -y -f git zsh supervisor unzip

/vagrant/scripts/adminer.sh
/vagrant/scripts/gogs.sh
/vagrant/scripts/ajenti.sh

sudo rm /etc/nginx/sites-enabled/default
sudo touch /etc/nginx/sites-enabled/default
sudo cat >> /etc/nginx/sites-enabled/default <<'EOF'
include /etc/nginx/sites-available/adminer;
EOF

sudo service nginx restart
sudo service php5-fpm restart
