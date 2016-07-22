###################
# Configuration :
####################

printf "Username to be created on the machine : "
read USERNAME
printf "Email of the user (for ssl certificates) : "
read EMAIL
printf "FQDN (Fully Qualified Domain Name, i.e. luke.jeanl.me) : "
read FQDN

# Add port 1935 to ssh, to be able to bypass the outbound firewall of some companies
# Please note that port 443 is already used by Nginx.
cp /etc/ssh/sshd_config /etc/ssh/sshd_config_default
sed -i '/Port 22/a Port 1935' /etc/ssh/sshd_config
service ssh restart

# Install fundamentals utilities
apt-get update
apt-get install -y tmux sudo git vim htop dnsutils

# If apache 2 is running : (for example ubuntu 15.10 ...)
scripts/0_uninstalling_apache2.sh

apt-get upgrade -y
# Add user with Sudo rights
adduser --ingroup sudo $USERNAME
# Configure the timezone
echo "Europe/Paris" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# Print colors in the prompt
scripts/1_color_prompt.sh
# Generatif SSL certificates and keys :
scruots/2_generate_ssl_keys.sh
# Install Nginx
scripts/3_install_nginx.sh

# Install Python & Anaconda
scripts/4_install_python3.sh
# Install Jupyterhub
scripts/5_install_jupyterhub.sh

# Install Codiad for C++/Java developments
scripts/6_install_codiad.sh 
# Install ShellInABox for remote ssh access
scripts/7_install_shellinabox
