#!/bin/sh

sudo adduser --disabled-login --gecos 'git' git
sudo adduser git sudo
sudo wget http://gogs.dn.qbox.me/gogs_v0.6.5_linux_amd64.zip -O /var/www/gogs.zip
cd /var/www/
unzip gogs.zip
rm gogs.zip
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
