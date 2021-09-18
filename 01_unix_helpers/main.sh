#!/bin/bash -xe

echo "--------------------------" > /dev/null
echo "------ UNIX HELPERS ------" > /dev/null
echo "--------------------------" > /dev/null
ROOT=$(dirname $0)


echo "------ Deploying Root directory ... ------" > /dev/null
chmod +x $ROOT/root/usr/sbin/adduser2
chmod +x $ROOT/root/usr/bin/configurebashrc
cp -R $ROOT/root/usr/* /usr/

echo "------ Creating empty directories ... ------" > /dev/null
mkdir -p /data/shared
chmod 777 /data/shared

echo "------ Configuring .bashrc of root ... ------" > /dev/null
configurebashrc

echo "------ Allowing all users of the 'wheel' group to have sudo privileges ... ------" > /dev/null
line_to_uncomment="\%wheel\tALL=(ALL)\tALL"
sed -i "s/# $line_to_uncomment/$line_to_uncomment/g" /etc/sudoers
