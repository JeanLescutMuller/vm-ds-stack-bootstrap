# Creating SSL key and Certificates for furhter HTTPS service

##############
# OPTION 1 : Letsencrypt certificate
##############
git clone https://github.com/certbot/certbot /usr/local/bin
/usr/local/bin/certbot/certbot-auto certonly -d $FQDN -m $EMAIL --standalone --agree-tos
KEY_PATH="/etc/letsencrypt/live/$FQDN/privkey.pem"
CERT_PATH="/etc/letsencrypt/live/$FQDN/fullchain.pem"
echo '5 3  * *  * root /usr/local/bin/certbot/certbot-auto renew --standalone --pre-hook "service nginx stop" --post-hook "service nginx start" -q' >> /etc/crontab


##############
# OPTION 2 : Self-signed certificate
##############
# sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/my_key.pem -out /etc/ssl/my_cert.pem
# KEY_PATH="/etc/ssl/my_key.pem"
# CERT_PATH="/etc/ssl/my_cert.pem"

