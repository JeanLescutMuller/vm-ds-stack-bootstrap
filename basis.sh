USERNAME="johndoe"

# Add port 1935 to ssh, to be able to bypass the outbound firewall of some companies
cp /etc/ssh/sshd_config /etc/ssh/sshd_config_default
sed -i '/Port 22/a Port 1935' /etc/ssh/sshd_config
service ssh restart

# Install fundamentals utilities
apt-get update
apt-get install -y tmux sudo git vim htop dnsutils

# If apache 2 is running : (for example ubuntu 15.10 ...)
./uninstalling_apache2.sh

apt-get upgrade -y

# Add user with Sudo rights
adduser --ingroup sudo $USERNAME

# Configure the timezone
echo "Europe/Paris" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# Print colors in the prompt
./color_prompt.sh

