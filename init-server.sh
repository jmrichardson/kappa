#!/bin/bash

# Make sure script run as root
if ! [ $(id -u) = 0 ]; then
   echo "Error: This script must be run as root (sudo)" 
   exit 1
fi

read -e -p "Setup cron time sync (yes/no): " -i "yes" cron
read -e -p "Setup smb share (yes/no): " -i "yes" smb
read -e -p "Install python dependencies (yes/no): " -i "yes" python
read -e -p "Reboot after installation (yes/no): " -i "yes" reboot

echo "alias dc='docker-compose'" >> ~/.bashrc

# Configure ES vm max
echo "Configuring Elasticsearch vm max" 
grep "262144" /etc/sysctl.conf > /dev/null
if [ $? -ne 0 ]; then
  echo "vm.max_map_count=262144" >> /etc/sysctl.conf
  sysctl -w vm.max_map_count=262144
fi

# Add ubuntu repositories
add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main universe restricted multiverse"

# Install docker engine and docker-compose
echo "Installing docerk engine"
apt install -y apt-transport-https ca-certificates curl software-properties-common 
[ $? -ne 0 ] && echo "Error: Unable to add repository requisites" && exit 1
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 
[ $? -ne 0 ] && echo "Error: Unable to add repository key" && exit 1
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" 
[ $? -ne 0 ] && echo "Error: Unable to add repository" && exit 1
apt update -y 
[ $? -ne 0 ] && echo "Error: Unable to update OS" && exit 1
apt install -y docker-ce
[ $? -ne 0 ] && echo "Error: Unable to install docker engine" && exit 1
usermod -aG docker ${SUDO_USER}
[ $? -ne 0 ] && echo "Error: Unable to add user to docker group" && exit 1
curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
[ $? -ne 0 ] && echo "Error: Unable to install docker-compose" && exit 1
chmod +x /usr/local/bin/docker-compose


# Build hadoop-common image
docker build -t hadoop-common /home/kappa/kappa/services/hadoop/common/.

### Setup SSH keys
### sudo -H -u kappa bash -c 'ssh-keygen -N "" -f ~/.ssh/id_rsa'

### Add node1, node2, etc  to /etc/hosts for name resolution
### TODO programatically add to host file
### https://www.digitalocean.com/community/tutorials/how-to-spin-up-a-hadoop-cluster-with-digitalocean-droplets


# Install NFS client
apt install -y rpcbind nfs-common nfs4-acl-tools
mkdir /data
chown ${SUDO_USER}:${SUDO_USER} /data

# Enable time sync
timedatectl set-ntp on

if [ "$cron" = "yes" ]; then
  # Allow for sudo commands without password (allows for chronyd updates in cron)
  grep "NOPASSWD: ALL" /etc/sudoers > /dev/null
  if [ $? -ne 0 ]; then
    echo "kappa ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  fi
  
  # Setup time sync every 5 minutes in chron
  apt install -y chrony
  if [ ! -f /var/spool/cron/crontabs/${SUDO_USER} ]; then
    echo "*/5 * * * * sudo chronyd -q" >> /var/spool/cron/crontabs/${SUDO_USER}
  fi
  chronyd -q
fi

if [ "$smb" = "yes" ]; then

  apt install -y samba cifs-utils

  grep "kappa" /etc/samba/smb.conf > /dev/null
  if [ $? -ne 0 ]; then
cat - << HERE >> /etc/samba/smb.conf
[kappa]
path = /home/kappa
available = yes
valid users = kappa
read only = no
browsable = yes
public = yes
writable = yes
HERE
  fi

fi

if [ "$python" = "yes" ]; then
  apt install -y python3.6 python3-setuptools python3-pip
  rm /usr/bin/python
  ln -s /usr/bin/python3 /usr/bin/python 
fi

if [ "$reboot" = "yes" ]; then
  reboot
fi
