# Install nginx from official sources
sudo apt-get install nginx

# Listening on port 443 for ssl (Uncommenting the line and removing an hypothetical server name)
sed -i '/listen 443/s/#.*$/listen 443 ssl;/' /etc/nginx/sites-available/default

# Changing server name
sed -i "/server_name/s/server_name.*$/server_name $FQDN;/" /etc/nginx/sites-available/default

# And just after, adding certificate and key
sed -i "/^[[:space:]]*server_name/a\        ssl_certificate_key $KEY_PATH;" /etc/nginx/sites-available/default
sed -i "/^[[:space:]]*server_name/a\        ssl_certificate $CERT_PATH;" /etc/nginx/sites-available/default
