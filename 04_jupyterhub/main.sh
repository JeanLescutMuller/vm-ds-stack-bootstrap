#!/bin/bash -xe

echo "-----------------------------------" > /dev/null
echo "------ INSTALLING JUPYTERHUB ------" > /dev/null
echo "-----------------------------------" > /dev/null
ROOT=$(dirname $0)
tempdir=${tempdir:-/tmp}
anaconda_location=${anaconda_location:-/opt/anaconda3}
service_system=${service_system:-SystemD} # "SystemV" or "SystemD"

# Source: 
echo "------ Installing Anaconda... ------" > /dev/null
if [ "$os" = "centos" ]; then
     yum install -y bzip2 # Required for Anaconda installation
elif [ "$os" = "debian" ]; then
     apt install -y bzip2 # Required for Anaconda installation
else
     exit 2
fi
filename="Anaconda3-2020.11-Linux-x86_64.sh" # Please update that 
wget -P $tempdir/ https://repo.anaconda.com/archive/$filename
chmod +x $tempdir/$filename
$tempdir/$filename -b -p $anaconda_location
rm $tempdir/$filename # To be clean (and the installer is big !)

echo "------ Installing JupyterHub... ------" > /dev/null
# Inspired from : https://gist.github.com/johnrc/604971f7d41ebf12370bf5729bf3e0a4
# Dependencies
curl --silent --location https://rpm.nodesource.com/setup_current.x | bash -
yum install -y nodejs
npm --version # Just checking # { (2017-10-03,2019-02-25) --> 3.10.10, (2021-04-28) --> 7.10.0 } 
node --version # Just checking # { (2017-10-03,) --> v6.11.3, (2019-02-25) --> v6.16.0, (2021-04-28) --> v16.0.0}
npm install -g configurable-http-proxy
# Installing Jupyterhub
/opt/anaconda3/bin/python3 -m pip install jupyterhub
/opt/anaconda3/bin/python3 -m pip install --upgrade notebook

# BUGFIX for SQLAlchemy : /opt/anaconda3/bin/python -m pip install SQLAlchemy==1.4.11
# BUGFIX for ruamel : /opt/anaconda3/bin/conda install ruamel.yaml

echo "------ Configuring permissions of Jupyterhub... ------" > /dev/null
groupadd jupyterhub_users
chown -R root:jupyterhub_users /opt/anaconda3

echo "------ Copying Configuration files... ------" > /dev/null
cp -R $ROOT/root/etc/jupyterhub /etc/
cp -R $ROOT/root/etc/nginx /etc/
cp -R $ROOT/root/var /

echo "------ Setting up Jupyterhub Service... ------" > /dev/null
echo $service_system
if [ "$service_system" == "SystemV" ]; then
     echo "Installing service in SystemV !"
     chmod +x $ROOT/root/etc/init.d/* # Setting right chmod for /root/* ..
     cp $ROOT/root/etc/init.d/* /etc/init.d/ # Using "/*" and not "-R" because /etc/init.d is a symlink
     chkconfig --add jupyterhub 
elif [ "$service_system" == "SystemD" ]; then
     echo "Installing service in SystemD !"
     cp -R $ROOT/root/etc/systemd /etc/
     systemctl enable jupyterhub.service 
fi

echo "------ Creating a label with Server's name in title + header of the page... ------" > /dev/null
# Finding the path with : root # grep -Erin '{% block headercontainer %}' / 2>/dev/null
html_file_path='./lib/python3.7/site-packages/notebook/templates/page.html'
cp $html_file_path $html_file_path.backup
sed -i 's/\(<title>\)/\1'$server_name':/' $html_file_path
sed -i '/{% block headercontainer %}/i <span style="line-height: 30px;margin-left: 20px;">&#9888; You are working on : <b>'$server_name'</b></span>' $html_file_path
sed -i '/{% endblock header_buttons %}/a <span><a href="./lab" class="btn btn-default btn-sm navbar-btn pull-right">Jupyter Lab</a></span>' $html_file_path

echo "------ (re)Starting Jupyterhub... ------" > /dev/null
service jupyterhub restart 

echo "------ Updating index.html and Restarting Nginx... ------" > /dev/null
/var/www/update_index.sh
service nginx restart
