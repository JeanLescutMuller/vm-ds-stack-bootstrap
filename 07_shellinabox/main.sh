# Installing ShellInABox
# Source : http://www.acmesystems.it/shellinabox

sudo apt-get install shellinabox

# I can't remember why I wrote all that below : 
# Whithout it, it works perfectly fine...
# mv /var/lib/shellinabox/certificate-luke.jeanl.me.pem /var/lib/shellinabox/certificate-luke.jeanl.me.pem.backup
# ln -sf /etc/letsencrypt/live/luke.jeanl.me/total.pem /var/lib/shellinabox/certificate-luke.jeanl.me.pem
# echo 'SHELLINABOX_ARGS="--localhost-only"' >> /etc/default/shellinabox
# sudo service shellinabox restart

