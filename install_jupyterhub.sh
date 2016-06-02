##########################################
# Installer Jupyterhub
# source : https://www.continuum.io/downloads
##########################################

# ------------------------------
# Installing Jupyterhub
# ------------------------------
sudo apt-get install npm nodejs-legacy
sudo npm install -g configurable-http-proxy
sudo apt-get install python3-pip
pip3 install jupyterhub
pip3 install --upgrade notebook

# ------------------------------
# Creating the daemon service
# ------------------------------
sudo su
cd /etc/init.d/
wget https://gist.githubusercontent.com/lambdalisue/f01c5a65e81100356379/raw/ecf427429f07a6c2d6c5c42198cc58d4e332b425/jupyterhub
chmod +x /etc/init.d/jupyterhub
mkdir /etc/jupyterhub/
jupyterhub --generate-config -f /etc/jupyterhub/jupyterhub_config.py

# Setting the Cert file
sed -i "/c.JupyterHub.ssl_cert/s/.*/c.JupyterHub.ssl_cert = '$(echo $CERT_PATH | sed 's/\//\\\//g')'/" /etc/jupyterhub/jupyterhub_config.py
# Setting the private key file
sed -i "/c.JupyterHub.ssl_key/s/.*/c.JupyterHub.ssl_key = '$(echo $KEY_PATH | sed 's/\//\\\//g')'/" /etc/jupyterhub/jupyterhub_config.py
# Setting the base url
sed -i "/c.JupyterHub.base_url/s/.*/c.JupyterHub.base_url = '\/jupyterhub\/'/" /etc/jupyterhub/jupyterhub_config.py
# We want the notebook to be reachable only from localhost :
sed -i "/c.JupyterHub.ip/s/.*/c.JupyterHub.ip = '127.0.0.1'/" /etc/jupyterhub/jupyterhub_config.py

sudo update-rc.d jupyterhub defaults
sudo service jupyterhub restart

# ------------------------------
# Adding the Nginx reverse proxy for jupyterhub
# ------------------------------
sed -i '/ssl_certificate_key/r jupyterhub_nginx_reverse_proxy' /etc/nginx/sites-available/default
