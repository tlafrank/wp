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
    
    echo '** Updating system'
#    apt-get -y update
#    apt-get -y upgrade
    
    echo '** Installing dependencies'
#    apt-get -y install apache2 ghostscript libapache2-mod-php mysql-server php php-bcmath php-curl php-imagick php-intl php-json php-mbstring php-mysql php-xml php-zip
    
    echo '** Downloading/deploying WP'
#    mkdir -p /var/www
#    chown www-data /var/www
#    curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /var/www
    
    echo 'Configuring Apache'
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
    
    while [[ true ]];
    do
      clear
      echo '1. Update/Upgrade'
      echo '2. Install Git'
      echo '3. Install Docker'
      echo '4. Remove SUDO Password Requirement (TBA)' 
      echo '5. Setup networking'
      echo '6. Setup database, node'
      echo 'Q. Exit'

      read -p "Selection: " choice

      case $choice in
        '1') update;;
        '2') install_git;;
        '3') install_docker;;
        '4') removeSudoPassword;;
        '5') setup_network;;
        '6') setup_database;;
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


#
#
function setup_database {
  echo "Use the appropriate script located in the helper folder"
}




#Install and conduct basic configuration of git
#Checked 6 Apr 19
function install_git() {
  apt-get -y install git

  read -p "Email to use for git registration: " email
  git config --global user.email $email

  read -p "Name to use for git registration: " name
  git config --global user.name $name
}

function install_docker {
  #Prefer this one
  add-apt-repository universe
  apt install -y docker.io
  
  #Add current user to docker group
  read -n 1 -p "Add the current user $USER to the docker group? (y/n)?" continue
  if [[ $continue =~ [yY] ]]; then
    echo "adding user"
    usermod -aG docker $USER
  fi
}

function install_docker2 {
  #Installs docker
  apt-get -y install apt-transport-https ca-certificates gnupg-agent software-properties-common
  
  #Add the GPG key
  wget -qO - https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
  
  apt-get -y update
  
  apt-get install docker-ce docker-ce-cli containerd.io

  #Add current user to docker group
  read -n 1 -p "Add the current user $USER to the docker group? (y/n)?" continue
  if [[ $continue =~ [yY] ]]; then
    echo "adding user"
    usermod -aG docker $USER
  fi

}

function removeSudoPassword {
  echo 'made it here'
  #sudo visudo
  
  #At the bottom, add:
  #$USER ALL=(ALL) NOPASSWD:ALL
}

function setup_network() {
  $DIR/helpers/network.sh
}

main "$@"
