# Make sure script run as root
if ! [ $(id -u) = 0 ]; then
   echo "Error: This script must be run as root (sudo)" 
   exit 1
fi

# Configure ES vm max
echo "Configuring Elasticsearch vm max" 
grep "262144" /etc/sysctl.conf > /dev/null
if [ $? -ne 0 ]; then
  echo "vm.max_map_count=262144" >> /etc/sysctl.conf
  sysctl -w vm.max_map_count=262144
fi

# Install docker engine
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
usermod -aG docker ${USER}
[ $? -ne 0 ] && echo "Error: Unable to add user to docker group" && exit 1
curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
[ $? -ne 0 ] && echo "Error: Unable to install docker-compose" && exit 1
chmod +x /usr/local/bin/docker-compose


