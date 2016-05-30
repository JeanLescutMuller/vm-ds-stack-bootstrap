# Configuration :
USERNAME="johndoe" # username to be created
EMAIL="johndoe@example.com" # email of the username (for ssl certificate)
FQDN="example.com" # for ssl certificate

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

# Creating SSL key and Certificates for furhter HTTPS service
cd /usr/local/bin
git clone https://github.com/certbot/certbot
cd certbot
./certbot-auto certonly -d $FQDN -m $EMAIL --standalone --agree-tos
KEY_PATH="/etc/letsencrypt/live/$FQDN/privkey.pem"
CERT_PATH="/etc/letsencrypt/live/$FQDN/fullchain.pem"
echo '5 3  * *  * root /usr/local/bin/certbot/certbot-auto renew --standalone --pre-hook "service nginx stop" --post-hook "service nginx start" -q' >> /etc/crontab

# Or self-signed (non-trusted) certificate :
# sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/my_key.pem -out /etc/ssl/my_cert.pem
# KEY_PATH="/etc/ssl/my_key.pem"
# CERT_PATH="/etc/ssl/my_cert.pem"





