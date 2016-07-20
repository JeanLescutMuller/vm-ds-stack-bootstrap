# Install nginx from official sources
sudo apt-get install nginx

###############
# OPTION 1 : change the whole config file, and prrofread everything
###############
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup
cp -f ./etc/nginx/sites-available/default /etc/nginx/sites-available/default



###############
# OPTION 2 : using sed to dynamically change nginx settings
# This part is not complete as it does not contain port 80 blocking, and restricted basic authentication access...
###############

# Listening on port 443 for ssl (Uncommenting the line and removing an hypothetical server name)
#sed -i '/listen 443/s/#.*$/listen 443 ssl;/' /etc/nginx/sites-available/default

# Changing server name
#sed -i "/server_name/s/server_name.*$/server_name $FQDN;/" /etc/nginx/sites-available/default

# And just after, adding certificate and key
#sed -i "/^[[:space:]]*server_name/a\        ssl_certificate_key $KEY_PATH;" /etc/nginx/sites-available/default
#sed -i "/^[[:space:]]*server_name/a\        ssl_certificate $CERT_PATH;" /etc/nginx/sites-available/default
