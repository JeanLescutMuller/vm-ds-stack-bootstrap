# Data Science stack server
This set of "bootstrap" scripts are designed to automatically install (on a raw, naked server) the necessary stack (set of services) necessary for a Data Scientist to work (or at least me !)

## Details of the stack :
All the IDE are cloud-based. This stack is :
- Some basics Unix tool & helpers
- Nginx
- **Jupyterhub, Anaconda and Python 3**
- **R and R Studio**
- **Spark**
- Shell-in-a-box, a cloud-based Terminal server
- Codiad and gc++ compiler for C++ development (to be used for the most adventurous of us !)
Even if it looks like `install.sh` can do all the work alone, I recommend to follow the scripts step by step.

## Compatibility :

### Infrastructure :
- Works on On-premise bareservers, VM & VPS (for `👨‍💻 Perso` server, for example)
- Works on AWS for EC2 or EMR clusters (`🔶 AWS EC2` for example)
- Works on GCP Compute Engine VMs (`🌀 GCP VertexAI VM` for example)

Note: I used these scripts to configure my "Luke" Personal Server

### OS :
Any common Linux distro : `🔵 Debian`, `🟢 Ubuntu`, `🔴 CentOS`, `🟡 RHEL` ...

## License
This script is Open-source, and I shared that freely under [Creative Common License](https://en.wikipedia.org/wiki/Creative_Commons_license) under "Attribution alone" terms. (code `BY`). Please click on the link if you're not familiar with these terms yet, in particular the clause of *Attribution*.
As long as the source (this repo) and the author (myself, Jean Lescut-Muller) is clearly displayed 
   - Any usage of these scripts, professional or not (for Commercial use or not) is: **allowed**
   - Any modification of the code is: **allowed**
   - Any copy of distribution of the code is: **allowed**

## Detailled usage :


### 0. (Optional) Create VM

#### AWS EC2

- OS: `Debian`, for example
- Instance type: one that supports Console, so `m6a.large`, for example
- keypair : choose same keypair for the region
- Allow HTTPS & HTTP traffic
- Advanced details -> User data :

```bash
#!/bin/bash -xe

echo "####### START OF USER DATA #######"
sleep 10 # to make sure other "System log" are not overlapping with these logs...

# GENERAL INFOS
# whoami
# pwd
# ls -la
# cat /etc/*release
# ls -la /etc/

# SSH CONFIG
# cat /etc/ssh/sshd_config
service sshd status
echo 'Port 443' >> /etc/ssh/sshd_config
# echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
tail /etc/ssh/sshd_config
service sshd restart
service sshd status

# ADDING ENRICES (METHOD 1)
which useradd
useradd -m -p '$6$4CdskT3jsbvLxHNB$f0wBALv2CyaG %%%% PLEASE REPLACE ME %%%% sCAyfVh3uul/' -s /bin/bash enrices
usermod -aG sudo enrices

# ADDING BACKDOOR (METHOD 2)
# Commenting these, because Method 1 works very well (and no password in clear text in the user data...)
# username=user_backdoor
# password= %%%%PLEASE REPLACE ME%%%%
# sudo adduser --gecos "" --disabled-password $username
# sudo chpasswd <<<"$username:$password"
# usermod -aG sudo $username

cat /etc/passwd

echo "####### END OF USER DATA #######"
```

### 1. Connect to the VM
- SSH (example `ssh -i ~/.ssh/jlescutmuller_rsa_passphrase.pem $admin_user@10.2.227.16`)
- AWS EC2 Serial Console
- ...

### 2. Install basic binaries & Clone this project

```bash
sudo su
cd # go to home
```

Installing base tools (Although only git is necessary at this stage)
<table><tr><td>

`🔵 Debian` `🟢 Ubuntu`
```bash
apt update && apt install -y git vim tree telnet wget
```

</td><td>

`🔴 CentOS` `🟡 RHEL`
```bash
yum update && yum install -y git vim tree telnet wget
```

</td></tr></table>

```bash
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

# For other users as well :
# add prefix host_color=31 for production environments
sudo -u enrices configurebashrc # 👨‍💻 Perso
sudo -u admin configurebashrc    # 🔶🔵 AWS EC2 Debian
# sudo -u centos configurebashrc # 🔶🔴 AWS EC2 CentOS
# sudo -u hadoop configurebashrc # 🔶🔶 AWS EMR
# sudo -u jupyter configurebashrc # 🌀 GCP VertexAI VM
```


### 4. (Optional) Dark theme for Jupyterlab in 🌀VertexAI :
<details>
   <summary>Optional Code :</summary>
   <pre>
# Make the JupyterLab Theme dark (to have a black Shell background in the Terminals)
# Or maybe just do that manually ?
exit
source ~/.bashrc
mkdir -p  ~/.jupyter/lab/user-settings/@jupyterlab/apputils-extension
echo '{"theme": "JupyterLab Dark"}' > ~/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings
  </pre>
</details>

### 5. (Optional) Mounting an EBS Volume to /data in 🔶AWS EC2 :
<details>
   <summary>More infos :</summary>
   
   - It is advised to create a ´/data´ folder on the machine and mount a persistent EBS volume on it.
   - More info on how-to at https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html
 
   <pre>
   mkfs -t xfs /dev/nvme1n1
   yum update -y && yum upgrade -y && yum install -y xfsprogs
   mkdir /data
   mount /dev/nvme1n1 /data
   </pre>
</details>

### 6. (Optional) Adding users  :
```bash
export home_dir='/data' # 🔶AWS EC2 with EBS volume mounted
export home_dir='/home' # default

./02_ssh_access/main.sh
# adduser2 pass these arguments to adduser. on CentOS, adduser can take "-p" argument to take the encrypted password.
# On such system (not on Debian-based), "man adduser" will give more information : using "crypt" to retrieve this code from clear/plain password
adduser2 jlescutmuller -d $home_dir/jlescutmuller -G wheel -p '$6$DKFej1xka8DYxrhi$HnlSzi4 ...... QGkHFpVK34zam2K8fFWbFu2AYvtLokqEJQtBxnWS8Mn9l71O1'
# adduser2 user2 -d $home_dir/user2 -G wheel -p '...' etc...
```

### 7. Installing Nginx :

```bash
# 🔴 CentOS :
cp $ROOT/root/etc/yum.repos.d/nginx.repo.centos /etc/yum.repos.d/nginx.repo
yum install -y nginx

# 🟡 RHEL :
cp $ROOT/root/etc/yum.repos.d/nginx.repo.rhel /etc/yum.repos.d/nginx.repo
yum install -y nginx

# 🔵 Debian, 🟢 Ubuntu :
apt install -y nginx

systemctl enable nginx
service nginx status
```

If possible, go to [http://ip_of_the_vm:80] and check the page


#### Configuring Nginx :

`🔵 Debian 11`
<table><tr><td>
   
1) No need to modify `/etc/nginx/nginx.conf`
2) `vim /etc/nginx/sites-available/default` :

  a) If you want, you can duplicates those lines and replace 80 by 8080 to duplicate nginx ports
```
listen 80 default_server;
listen [::]:80 default_server;
```
  b) add the location folder :
```
include /etc/nginx/location.d/*.conf;
```
   
2b) Or automatic way :
   ```bash
   sed -i $'/# Default server configuration/{e cat 03_nginx/root/etc/nginx/sites-available/default.addon1.conf\n}' /etc/nginx/sites-available/default
   sed -i $'/# SSL configuration/{e cat 03_nginx/root/etc/nginx/sites-available/default.addon2.conf\n}' /etc/nginx/sites-available/default
   ```
   
3) 
   ```bash
   mkdir /etc/nginx/location.d
   nginx -t # Check configuration file
   service nginx restart
   service nginx status
   ```
   
</td></tr></table>

`🔴 CentOS` `🟡 RHEL`
<table><tr><td>Please see script</td></tr></table>

#### Generating Home Page :
```bash
cp -R ./03_nginx/root/var/www /var/
chmod +x /var/www/update_index.sh
/var/www/update_index.sh
```
If possible, go to [http://ip_of_the_vm:80] and check the page

Tip: AWS Console will always redirect you to HTTP**S** . You need to manually remove this **S** 


### 8. Installing Anaconda

<table><tr><td>
  
`🔵 Debian` `🟢 Ubuntu`
```bash
apt install -y bzip2
```

</td><td>

`🔴 CentOS` `🟡 RHEL`
```bash
yum install -y bzip2
```
  
</td></tr><tr><td>

`🔶🔶 AWS EMR Cluster`
```bash
export tempdir='/dev/shm'
```
</td><td>

`Everything else`
```bash
export tempdir='/tmp'
```
 
</td></tr></table>

- Go to https://repo.anaconda.com/archive and copy link of most recent installer.
- Note : the default installation path is `/root/anaconda3`, but you cannot use a non-root-service if we choose this. On internet, `/opt/anaconda3` is very popular, so keeping this instead.

```bash
url="https://repo.anaconda.com/archive/Anaconda3-2023.03-1-Linux-x86_64.sh" # Please update that 
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
# ... etc...
```

### 9.1 (Option 1) Configuring Jupyter(lab) :
```bash
cp ./04_jupyterhub/root/opt/anaconda3/etc/jupyter/jupyter_lab_config.py /opt/anaconda3/etc/jupyter/
```

### 9.2 (Option 2) Installing & Configuring JupyterHub :
Please see scripts for installation...
```bash
cp ./04_jupyterhub/root/etc/jupyterhub /etc/
```

### 9.3 Test JupyterHub / JupyterLab directly without reverse proxy
For example, using port 80 :
```bash
service nginx stop

# Then choose 1 :
# /opt/anaconda3/bin/jupyter lab --port=80
# /opt/anaconda3/bin/jupyter lab -f /opt/anaconda3/etc/jupyter/jupyter_lab_config.py --port=80

# Go to the webpage of the server (HTTP, TCP 80) and check on /jupyter
# For example http://18.138.212.239/jupyter
```

⚠⚠⚠ **You need to do this step to configure jupyter lab password**
Set up password (using token from terminal)

### 9.4 Setup Nginx reverse-proxy for JupyterHub / JupyterLab

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
cp ./04_jupyterhub/root/etc/nginx/location.d/jupyter.conf /etc/nginx/location.d/
``` 

#### Testing :
```bash
nginx -t # to test configuration
service nginx start
service nginx status

# choose :
/opt/anaconda3/bin/jupyter lab
/opt/anaconda3/bin/jupyter lab -f /opt/anaconda3/etc/jupyter/jupyter_lab_config.py

# go on website and check.
# go to /jupyter/ and check
```

#### Adding logo link on home page :

For example for Jupyterlab :
```bash
mkdir /var/www/html/html_links/
cp ./04_jupyterhub/root/var/www/html/html_links/jupyter.html /var/www/html/html_links/
mkdir /var/www/html/res/logos
cp ./04_jupyterhub/root/var/www/html/res/logos/jupyter.png /var/www/html/res/logos/
/var/www/update_index.sh
```

### 9.5 Setting up Jupyterhub/JupyterLab service :

#### Which service system is on the machine ? SystemV or SystemD ?
We always prefer SystemD, if possible.
You can check if systemD is installed with :
```bash
ls /etc/systemd
```

#### SystemD :
```bash
# CHOOSE BETWEEN :
appname="jupyterlab"
# appname="jupyterhub"

cp ./04_jupyterhub/root/etc/systemd/system/$appname.service /etc/systemd/system/
service $appname start
service $appname status
systemctl enable $appname.service # to start on boot
```

# Bonus :

## Configure git :

```bash
exit # go back to your non-privileged account

# Configure GIT :
git config --global pull.rebase false
git config --global user.name "Jean Lescut-Muller"
git config --global user.email "jean.lescut@gmail.com"

# Install Jupyterlab GIT Extension
sudo /opt/anaconda3/bin/pip install --upgrade jupyterlab jupyterlab-git
chown -R root:anaconda_users /opt/anaconda3/
sudo reboot
```

## Change color and Server-label Jupyterlab :

```bash
# Please adapt the path to 1) the user and 2) the desired theme (dark or light) to be altered
# Choose 1 :
path='/home/enrices/.local/share/jupyter/lab/themes/@jupyterlab/theme-dark-extension/index.css'
path='/opt/anaconda3/share/jupyter/lab/themes/@jupyterlab/theme-dark-extension/index.css'

# server_name='Frankfurt-1'
# color_text='#b8b8ff'  # Light Purple
# color_border='#7b3dd2' # Purple

server_name='Frankfurt-2'
color_text='#7e9dff'   # Light Blue
color_border='#3151b8' # Blue

# server_name='Frankfurt-3'
# color_text='#23d9e6' # Flashy Cyan
# color_border='#3eafb7' # Paste Cyan

# server_name='Frankfurt-4'
# color_text='#33e232' # Flashy Green
# color_border='#3fb73e' # Pastel Green

sed -i "/--jp-layout-color3:/c\  --jp-layout-color3: $color_border;" $path
sed -i $'/:root/{e cat 04_jupyterhub/server_label.css\n}' $path

# Or just VIM at this point...
# sed -i "/--jp-layout-color3:/c\  --jp-layout-color1: $color;" $path
# sed -i "s/SERVER_NAME/$server_name/g" $path
```


Palet : 🔴🟠🟡🟢🔵🟣🟤⚫⚪
