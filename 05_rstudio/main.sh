#!/bin/bash -xe

echo "--------------------------------" > /dev/null
echo "------ INSTALLING RSTUDIO ------" > /dev/null
echo "--------------------------------" > /dev/null
ROOT=$(dirname $0)
tempdir=${tempdir:-/tmp}

echo "----- Installing R... -----" > /dev/null
sudo yum install -y epel-release
sudo yum update
sudo yum install -y R

echo "------ Installing RStudio... ------" > /dev/null
filename="rstudio-server-rhel-1.1.453-x86_64.rpm" # Please change that whenever you want
wget -P $tempdir/ https://download2.rstudio.org/$filename
yum install $tempdir/$filename -y
rm $tempdir/$filename # To be clean (and the installer is big !)

echo "------ Configuring permissions of RStudio... ------" > /dev/null
#groupadd rstudio_users
#chown -R root:jupyterhub_users /opt/anaconda3

echo "------ Override of bootstrap root... ------" > /dev/null
cp -R $ROOT/root/etc/nginx /etc/
cp -R $ROOT/root/var /

echo "------ Updating index.html and Restarting Nginx... ------" > /dev/null
/var/www/update_index.sh
service nginx restart
