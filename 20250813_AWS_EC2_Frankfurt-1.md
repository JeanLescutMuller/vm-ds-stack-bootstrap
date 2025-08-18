This is a log of what has been succesfully done/deployed (and can be repeated) for :
- Provider : AWS
- Type : EC2 (t2 instance)
- Debian 12
- Jupyterlab (no JupyterHub, no Shell-in-a-box, etc...)

### 0. Create VM

- OS: `Debian`, for example
- Instance type: one that supports Console, so `m6a.large`, for example
- keypair : choose same keypair for the region
- Allow HTTPS & HTTP traffic
- Advanced details -> User data :

```bash
#!/bin/bash -xe

echo "############## START OF USER DATA ##############"

# -------------------------------------------
# GENERAL INFOS
# -------------------------------------------
# whoami
# pwd
# ls -la
# cat /etc/*release
# ls -la /etc/

# -------------------------------------------
# SSH CONFIG
# -------------------------------------------
# cat /etc/ssh/sshd_config

SSHD_CONF="/etc/ssh/sshd_config"

# If a line with PasswordAuthentication exists (even commented), replace it
if grep -q -E '^\s*#?\s*PasswordAuthentication\s+' "$SSHD_CONF"; then
    echo "Changing the PasswordAuthentication line to yes (And potentially uncommenting it)"
    sudo sed -i -E 's|^\s*#?\s*PasswordAuthentication\s+.*|PasswordAuthentication yes|' "$SSHD_CONF"
else
    echo "Appending PasswordAuthentication yes to $SSHD_CONF"
    echo "PasswordAuthentication yes" | sudo tee -a "$SSHD_CONF" > /dev/null
fi

# Ensure Port 443 is set
if grep -q -E '^\s*#?\s*Port\s+' "$SSHD_CONF"; then
    echo "Changing Port to 443"
    sudo sed -i -E 's|^\s*#?\s*Port\s+.*|Port 443|' "$SSHD_CONF"
else
    echo "Appending Port 443 at the end of $SSHD_CONF"
    echo "Port 443" | sudo tee -a "$SSHD_CONF" > /dev/null
fi

service sshd restart
service sshd status

# -------------------------------------------
# ADDING ENRICES (METHOD 1)
# -------------------------------------------
which useradd
useradd -m -p '{PLEASE REPLACE ME}' -s /bin/bash enrices
usermod -aG sudo enrices

# ADDING BACKDOOR (METHOD 2)
# Commenting these, because Method 1 works very well (and no password in clear text in the user data...)
# username=user_backdoor
# password= # Please write clear-text password here
# sudo adduser --gecos "" --disabled-password $username
# sudo chpasswd <<<"$username:$password"
# usermod -aG sudo $username

cat /etc/passwd

echo "############## END OF USER DATA ##############"
```

### 1. Connect to the VM
- SSH (example `ssh -i ~/.ssh/jlescutmuller_rsa_passphrase.pem $admin_user@10.2.227.16`)
- AWS EC2 Serial Console
- ...

### 2. Install basic binaries & Clone this project

Make yourself root :
```bash
sudo su
```
And then from root :
```bash
cd # go to home
apt update && apt install -y git vim tree telnet wget
git clone https://github.com/JeanLescutMuller/DataScience_stack_server.git
cd ./DataScience_stack_server
```

### 3. Setting up .bashrc for users :

```bash
# For root :
chmod +x ./01_unix_helpers/root/usr/sbin/adduser2
chmod +x ./01_unix_helpers/root/usr/bin/configurebashrc
cp -R ./01_unix_helpers/root/* /
configurebashrc # root
# host_color=31 configurebashrc # for PROD environment (make hostname RED)
source ~/.bashrc
sudo -u enrices configurebashrc # 👨‍💻 Perso
# Note : I didnt do it for user "admin" since I am using "enrices" as a user (Added it in the user data script)

# Changing the hostname :
hostnamectl set-hostname frankfurt-1 # Change this to match name in EC2 interface
vim /etc/cloud/cloud.cfg # I am NOT sure it is useful to make it persistent at reboot, but you could change `preserve_hostname: false` to `preserve_hostname: true`
```



### 7. Installing Nginx :

```bash
apt install -y nginx
systemctl enable nginx
service nginx status
```

Go to [http://{ip}:80] and check the page (Not HTTPS, HTTP !)


#### Configuring Nginx :

1) No need to modify `/etc/nginx/nginx.conf`
2) `vim /etc/nginx/sites-available/default` :

  a) If you want, you can duplicates those lines and replace 80 by 8080 to duplicate nginx ports
```
listen 80 default_server;
listen [::]:80 default_server;
```
  b) Make the Websockets work (2025-08: This is necessary for Jupyter... and redundant with below)
Look at the output of `sed $'/# Default server configuration/{e cat 03_nginx/root/etc/nginx/sites-available/default.addon1.conf\n}' /etc/nginx/sites-available/default` and compare it with `/etc/nginx/sites-available/default` for validation. Then you can add a `-i` after sed to modify the file in-place.

c) Include `/etc/nginx/location.d/*.conf` so I can add Jupyter config, etc... separately.
Look at the output of `sed $'/# SSL configuration/{e cat 03_nginx/root/etc/nginx/sites-available/default.addon2.conf\n}' /etc/nginx/sites-available/default` and compare it with `/etc/nginx/sites-available/default` for validation. Then you can add a `-i` after sed to modify the file in-place.
   
3) 
```bash
mkdir /etc/nginx/location.d
nginx -t # Check configuration file
service nginx restart
service nginx status
```

#### Generating Home Page :
```bash
cp -R ./03_nginx/root/var/www /var/
chmod +x /var/www/update_index.sh
/var/www/update_index.sh
```
If possible, go to [http://ip_of_the_vm:80] and check the page (Not HTTPS, HTTP !)


### 8. Installing Anaconda

```bash
apt install -y bzip2
export tempdir='/tmp'
```

- Go to https://repo.anaconda.com/archive and copy link of most recent installer.
- Note : the default installation path is `/root/anaconda3`, but you cannot use a non-root-service if we choose this. On internet, `/opt/anaconda3` is very popular, so keeping this instead.

```bash
url="https://repo.anaconda.com/archive/Anaconda3-2025.06-1-Linux-x86_64.sh" # Please update that 
wget $url -O $tempdir/Anaconda.sh
bash $tempdir/Anaconda.sh -b -p /opt/anaconda3 # Agreeing with License, installing to /opt/anaconda3
rm $tempdir/Anaconda.sh # To be clean (and the installer is big !)
```

Group for permissions :
```bash
groupadd anaconda_users
chown -R root:anaconda_users /opt/anaconda3
# Adding users to the group :
usermod -aG anaconda_users enrices
```

### 9. Configuring Jupyterlab :
```bash
cp ./04_jupyter/root/opt/anaconda3/etc/jupyter/jupyter_lab_config.py /opt/anaconda3/etc/jupyter/
```

### 9.3 Test JupyterLab directly (without reverse proxy)
For example, using port 80 :
```bash
service nginx stop

# Then :
/opt/anaconda3/bin/jupyter lab --config=/opt/anaconda3/etc/jupyter/jupyter_lab_config.py --no-browser --port=80

# Go to the webpage of the server (HTTP, TCP 80) and check on /jupyter/
# For example http://18.138.212.239/jupyter/ (just check if jupyter receive some packets.)
```

### 9.4 Setup Nginx reverse-proxy for JupyterLab

#### /etc/nginx/sites-available/default :

1) Adding connection_upgrade variable :
Source : https://jupyterhub.readthedocs.io/en/stable/reference/config-proxy.html
**Before** `server {`, add : (`:set paste` can help in vim)
```
# Top-level HTTP config for WebSocket headers
# If Upgrade is defined, Connection = upgrade
# If Upgrade is empty, Connection = close
map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
}
```

2) Bugfix (not sure if it's still needed...)
**Inside** `server {`, add :
```
        # Bugfix: 'Request Entity too large' while saving in Jupyterhub
        # Source 1: https://www.cyberciti.biz/faq/linux-unix-bsd-nginx-413-request-entity-too-large/
        # Source 2: https://github.com/jupyterlab/jupyterlab/issues/4214
        client_max_body_size 100M;
``` 

#### add location.d :
```bash
cp ./04_jupyter/root/etc/nginx/location.d/jupyter.conf /etc/nginx/location.d/
```

#### Testing and Setting up Jupyter password :
```bash
nginx -t # to test configuration
service nginx start
service nginx status

# Testing Jupyterlab :
/opt/anaconda3/bin/jupyter lab --config=/opt/anaconda3/etc/jupyter/jupyter_lab_config.py --no-browser
# Go to {ip}/jupyter/ and check if :
# 1) On terminal : jupyter receive some packets.
# 2) On browser : No token are being asked, and you can just use password (hash present in /opt/anaconda3/etc/jupyter/jupyter_lab_config.py)
```

#### Adding logo link on home page :

```bash
mkdir /var/www/html/html_links/
cp ./04_jupyter/root/var/www/html/html_links/jupyter.html /var/www/html/html_links/
mkdir /var/www/html/res/logos
cp ./04_jupyter/root/var/www/html/res/logos/jupyter.png /var/www/html/res/logos/
/var/www/update_index.sh
```

### 9.5 Setting up Jupyterhub/JupyterLab service :

```bash
appname="jupyterlab"
cp ./04_jupyter/root/etc/systemd/system/$appname.service /etc/systemd/system/
service $appname start
service $appname status
systemctl enable $appname.service # to start on boot
```

## Configure git & JupyterLab-git extension

```bash
git config --global pull.rebase false
git config --global user.name "Jean Lescut-Muller"
git config --global user.email "jean.lescut@gmail.com"

exit # go back to your non-privileged account

# Configure GIT :
git config --global pull.rebase false
git config --global user.name "Jean Lescut-Muller"
git config --global user.email "jean.lescut@gmail.com"

# Install Jupyterlab GIT Extension
sudo /opt/anaconda3/bin/pip install --upgrade jupyterlab jupyterlab-git
sudo chown -R root:anaconda_users /opt/anaconda3/ # 2025-08: I am assuming owner group changed for some folders. This command normally takes a bit of time.
sudo reboot
```

## Change color and Server-label Jupyterlab :

```bash
path='/opt/anaconda3/share/jupyter/lab/themes/@jupyterlab/theme-dark-extension/index.css'
server_name='Frankfurt-1'
color_text='#b8b8ff'  # Light Purple
color_border='#7b3dd2' # Purple

cp $path "$path.backup" # Making a backup
sed -i "/--jp-layout-color3:/c\  --jp-layout-color3: $color_border;" $path # Replacing "layout-color3" by our value "$color_border"
export server_name color_text # Exporting variables so we can use envsubst below (into a temp file)
envsubst < 04_jupyter/server_label.css.template > $tempdir/server_label.css
sed -i $'/:root/{e cat $tempdir/server_label.css\n}' $path # Adding the content of the temp file in the css
```

### 4. Dark theme for Jupyterlab :
I actually just changed it in the GUI...
