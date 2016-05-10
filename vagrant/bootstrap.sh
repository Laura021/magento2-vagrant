#!/usr/bin/env bash


echo "=================================================="
echo "Aloha! Now we will try to Install Ubuntu 14.04 LTS"
echo "with Nginx , PHP 5.6, MySQL 5.6(manual)"
echo "and others dependencies needed for Magento 2."
echo "Good luck :P"
echo "=================================================="


echo "=================================================="
echo "SET LOCALES"
echo "=================================================="

export DEBIAN_FRONTEND=noninteractive

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US en_US.UTF-8
dpkg-reconfigure locales


echo "=================================================="
echo "RUN UPDATE"
echo "=================================================="

apt-get update
apt-get upgrade


echo "=================================================="
echo "INSTALLING PHP5-FPM"
echo "=================================================="

apt-get -y install php5-fpm
# Still need to mod file nano /etc/php5/fpm/pool.d/www.conf
# Add listen = /var/run/php5-fpm.sock
# listen.owner = www-data
# listen.group = www-data
# listen.mode = 0660
 
echo "=================================================="
echo "INSTALLING NGINX"
echo "=================================================="

apt-get -y install nginx 


sudo rm /etc/nginx/sites-available/default
sudo touch /etc/nginx/sites-available/default

sudo cat >> /etc/nginx/sites-available/default <<'EOF'
server {
  listen   80;

  root /usr/share/nginx/www;
  index index.php index.html index.htm;

  # Make site accessible from http://localhost/
  server_name _;

  location / {
    # First attempt to serve request as file, then
    # as directory, then fall back to index.html
    try_files $uri $uri/ /index.html;
  }

  location /doc/ {
    alias /usr/share/doc/;
    autoindex on;
    allow 127.0.0.1;
    deny all;
  }

  # redirect server error pages to the static page /50x.html
  #
  error_page 500 502 503 504 /50x.html;
  location = /50x.html {
    root /usr/share/nginx/www;
  }

  # pass the PHP scripts to FastCGI server listening on /tmp/php5-fpm.sock
  #
  location ~ \.php$ {
    try_files $uri =404;
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass unix:/var/run/php5-fpm.sock;
    fastcgi_index index.php;
    include fastcgi_params;
  }

  # deny access to .htaccess files, if Apache's document root
  # concurs with nginx's one
  #
  location ~ /\.ht {
    deny all;
  }
}
EOF

sudo touch /usr/share/nginx/www/info.php
sudo cat >> /usr/share/nginx/www/info.php <<'EOF'
<?php phpinfo(); ?>
EOF

sudo service nginx restart


echo "=================================================="
echo "INSTALLING PHP"
echo "=================================================="

apt-get -y update
apt-get install python-software-properties
add-apt-repository ppa:ondrej/php5-5.6
apt-get -y update
apt-get -y install php5 php5-curl php5-gd php5-imagick php5-intl php5-mcrypt php5-mhash php5-mysql php5-cli  php5-xsl

sudo service php5-fpm
sudo service nginx restart


echo "=================================================="
echo "INSTALLING COMPOSER"
echo "=================================================="
# If you have troubles please review https://getcomposer.org/download/
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '92102166af5abdb03f49ce52a40591073a7b859a86e8ff13338cf7db58a19f7844fbc0bb79b2773bf30791e935dbd938') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer


echo "=================================================="
echo "INSTALLING and CONFIGURE NTP"
echo "=================================================="
apt-get -y install ntp


echo "=================================================="
echo "INSTALLING MYSQL and CONFIGURE DATABASE"
echo "======== ATTENTION!!! READ THIS PLEASE ==========="
echo ""
echo "MySQL 5.6 need to be installed manually."
echo "Please run next command and enter password or whatever system will ask you..."
echo ""
echo "$ sudo apt-get install mysql-server-5.6 mysql-client-5.6 && mysql_secure_installation"
echo "$ sudo apt-get -y autoremove && sudo apt-get -y autoclean"
echo ""
echo "After MySQL Installation complete run:"
echo "$ mysql -u root -p"
echo "> create database magento;"
echo "> GRANT ALL ON magento.* TO magento@localhost IDENTIFIED BY 'magento';"
echo "=================================================="


echo "=================================================="
echo "CLEANING..."
echo "=================================================="
apt-get -y autoremove
apt-get -y autoclean


echo "=================================================="
echo "============= INSTALLATION COMPLETE =============="
echo "=================================================="
