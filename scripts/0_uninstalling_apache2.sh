# Source : http://askubuntu.com/questions/176964/permanently-removing-apache2

# 1. First, stop apache2
service apache2 stop

# 2. Uninstall Apache2 and its dependent packages
apt-get purge apache2*

# 3. Also use autoremove option to get rid of other dependencies
apt-get autoremove

# 4. Check whether there are any configuration files have not been removed
# $ whereis apache2
# If you get a response as follows apache2: /etc/apache2

# Remove the directory and existing configuration files
rm -rf /etc/apache2

# Warning ! this will remove all websites on the server !
rm -rf /var/www/
