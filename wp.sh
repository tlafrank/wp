#!/bin/bash
#Use git clone https://gitbub.com/tlafrank/wp


#Constants
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"

function main() {
  #Check that the script is being run as SUDO.
  if [ "root" = $USER ]; then
    #Running as sudo, as expected
    
    echo '** Commencing setup for WordPress'
    echo '** Based off the guide available at https://ubuntu.com/tutorials/install-and-configure-wordpress#1-overview'
   
    while [[ true ]];
    do
      #clear
      echo '1. Update/Upgrade'
      echo '2. Install Dependencies'
      echo '3. Download/Deploy Wordpress'
      echo '4. Configure Apache' 
      echo '5. Configure MySQL'
      echo '6. Configure Wordpress'
      echo 'Q. Exit'

      read -p "Selection: " choice

      case $choice in
        '1') update;;
        '2') install_dependencies;;
        '3') deployWP;;
        '4') configureApache;;
        '5') configureMysql;;
        '6') configureWordpress;;
        
        'Q') break;;
        'q') break;;
        *) echo "Invalid Selection";;
      esac
      read -n 1 -p "Press any key to continue..."
    done
  else
    echo 'Script is not running as SUDO (required). Exiting with no changes.'
  fi
}

#Update packages
#Checked 21 Apr 23
function update() {
    echo '** Updating system'
    apt-get -y update
    apt-get -y upgrade
}

#Install dependencies
#Checked 21 Apr 23
function install_dependencies() {
    echo '** Installing dependencies'
    apt-get -y install apache2 ghostscript libapache2-mod-php mysql-server php php-bcmath php-curl php-imagick php-intl php-json php-mbstring php-mysql php-xml php-zip
}

function deployWP {
    echo '** Downloading/deploying WP to /var/www'
    mkdir -p /var/www
    chown www-data /var/www
    curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /var/www
}

function configureApache {
    echo '** Configuring Apache'
    touch /etc/apache2/sites-available/wordpress.conf
    cat > /etc/apache2/sites-available/wordpress.conf << EOF
    <VirtualHost *:80>
      DocumentRoot /var/www/wordpress
      <Directory /var/www/wordpress>
          Options FollowSymLinks
          AllowOverride Limit Options FileInfo
          DirectoryIndex index.php
          Require all granted
      </Directory>
      <Directory /var/www/wordpress/wp-content>
          Options FollowSymLinks
          Require all granted
      </Directory>
    </VirtualHost>
EOF

    a2ensite wordpress
    a2enmod rewrite
    a2dissite 000-default
    service apache2 reload
}



function configureMysql {
    echo '** Configure MySQL'
    mysql -u root -e "DROP SCHEMA IF EXISTS wordpress;"
    mysql -u root -e "CREATE DATABASE wordpress;"
    mysql -u root -e "DROP USER IF EXISTS wordpress@localhost"
    mysql -u root -e "CREATE USER wordpress@localhost IDENTIFIED BY '342gd45gtehtr'"
    mysql -u root -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON wordpress.* TO wordpress@localhost;"
    mysql -u root -e "FLUSH PRIVILEGES;"
    service mysql restart
}

function configureWordpress {
    echo '** Configure Wordpress'
    sudo -u www-data cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php
    sudo -u www-data sed -i 's/database_name_here/wordpress/' /var/www/wordpress/wp-config.php
    sudo -u www-data sed -i 's/username_here/wordpress/' /var/www/wordpress/wp-config.php
    sudo -u www-data sed -i 's/password_here/342gd45gtehtr/' /var/www/wordpress/wp-config.php
    
    sudo -u www-data sed -i "/define( 'AUTH_KEY'/d" /var/www/wordpress/wp-config.php
    sudo -u www-data sed -i "/define( 'SECURE_AUTH_KEY'/d" /var/www/wordpress/wp-config.php
    sudo -u www-data sed -i "/define( 'LOGGED_IN_KEY'/d" /var/www/wordpress/wp-config.php
    sudo -u www-data sed -i "/define( 'NONCE_KEY'/d" /var/www/wordpress/wp-config.php
    sudo -u www-data sed -i "/define( 'AUTH_SALT'/d" /var/www/wordpress/wp-config.php
    sudo -u www-data sed -i "/define( 'SECURE_AUTH_SALT'/d" /var/www/wordpress/wp-config.php
    sudo -u www-data sed -i "/define( 'LOGGED_IN_SALT'/d" /var/www/wordpress/wp-config.php
    sudo -u www-data sed -i "/define( 'NONCE_SALT'/d" /var/www/wordpress/wp-config.php

    curl https://api.wordpress.org/secret-key/1.1/salt/ | sudo tee -a /var/www/wordpress/wp-config.php
}



main "$@"
