#!/bin/bash -xe

echo "------------------------------" > /dev/null
echo "------ INSTALLING NGINX ------" > /dev/null
echo "------------------------------" > /dev/null
ROOT=$(dirname $0)


echo "------ Installing nginx... ------" > /dev/null
if [ "$os" == "centos" ]; then
    cp $ROOT/root/etc/yum.repos.d/nginx.repo.centos /etc/yum.repos.d/nginx.repo
    yum install -y nginx
elif [ "$os" == "rhel" ]; then
    cp $ROOT/root/etc/yum.repos.d/nginx.repo.rhel /etc/yum.repos.d/nginx.repo
    yum install -y nginx
elif [ "$os" == "debian" ]; then
    apt install -y nginx
else
    echo "ERROR : Could not install Nginx on os='$os' !"
    exit 1
fi

echo "------ Backup of files that would be overridden by bootstrap root... ------" > /dev/null
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
echo "------ Override of bootstrap root... ------" > /dev/null
cp -R $ROOT/root/etc/nginx/* /etc/nginx/
cp -R $ROOT/root/var/www /var/

# Allowing all the relevant ports to be routed to Nginx :
if [ -z $services_ports ]; then
   # By default, allow these ports :
   services_ports=(80 8080)
fi
for port in "${services_ports[@]}"
do
   sed -i "s/server {/server {\n\tlisten       [::]:$port default_server;/" /etc/nginx/nginx.conf
   sed -i "s/server {/server {\n\tlisten       $port default_server;/" /etc/nginx/nginx.conf
done


echo "------ Generating index.html ... ------" > /dev/null
chmod +x /var/www/update_index.sh
/var/www/update_index.sh

echo "------ Starting nginx... ------" > /dev/null
service nginx start

echo "------ Enabling nginx to run on boot ------" > /dev/null
systemctl enable nginx
