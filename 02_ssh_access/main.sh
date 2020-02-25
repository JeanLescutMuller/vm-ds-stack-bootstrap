#!/bin/bash -xe

home_dir=${home_dir:-/home} # By default, install user homes into /home ...

echo "------ Allowing Users to Authenticate using passwords... ------" > /dev/null
sed -i 's/\(PasswordAuthentication\) no/\1 yes/' /etc/ssh/sshd_config
service sshd restart
