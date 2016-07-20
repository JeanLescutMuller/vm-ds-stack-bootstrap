##########################################
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
# Settings
# ------------------------------
mkdir -p /etc/jupyterhub/
jupyterhub --generate-config -f /etc/jupyterhub/jupyterhub_config.py.backup
cp ./root/etc/jupyterhub/jupyterhub_config.py /etc/jupyterhub/


# ------------------------------
# Creating the daemon service
# ------------------------------
cp ./root/etc/systemd/system/jupyterhub.service /etc/systemd/systemd/
sudo service jupyterhub start


