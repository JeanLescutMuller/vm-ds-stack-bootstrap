# Creating SSL key and Certificates for furhter HTTPS service

##############
# OPTION 1 : Letsencrypt certificate
##############
git clone https://github.com/certbot/certbot /usr/local/bin/certbot
/usr/local/bin/certbot/certbot-auto certonly -d $FQDN -m $EMAIL --standalone --agree-tos
KEY_PATH="/etc/letsencrypt/live/$FQDN/privkey.pem"
CERT_PATH="/etc/letsencrypt/live/$FQDN/fullchain.pem"

cp -r ./root/usr/local/bin/certbot-addin /usr/local/bin/

echo'# Letsencrypt certificates last for 90 days.' >> /etc/crontab
echo '# We have to renew them. The cron is to run daily, but the certificate is actually renewed if less than 30 days to expire.' >> /etc/crontab
echo '5 3  * *  * root /usr/local/bin/certbot/certbot-auto renew --standalone --pre-hook "/usr/local/bin/certbot-addin/pre-hook.sh" --post-hook "/usr/local/bin/certbot-addin/post-hook.sh" -q' >> /etc/crontab

##############
# OPTION 2 : Self-signed certificate
##############
# sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/my_key.pem -out /etc/ssl/my_cert.pem
# KEY_PATH="/etc/ssl/my_key.pem"
# CERT_PATH="/etc/ssl/my_cert.pem"

