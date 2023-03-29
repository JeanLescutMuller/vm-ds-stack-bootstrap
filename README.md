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
   - Any usage of these scripts, professional or not, for Commercial use or not **is allowed**
   - Any modification of the code **is allowed**
   - Any copy of distribution of the code **is allowed**

## Detailled usage :

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

For root :
```bash
chmod +x ./01_unix_helpers/root/usr/sbin/adduser2
chmod +x ./01_unix_helpers/root/usr/bin/configurebashrc
cp -R ./01_unix_helpers/root/* /
configurebashrc # root
source ~/.bashrc
sudo -u $admin_user configurebashrc # non-root (main user)
```

Define admin user :
```bash
export admin_user='enrices' # 👨‍💻 Perso
export admin_user='jupyter' # 🌀 GCP VertexAI VM
export admin_user='centos' # 🔶🔴 AWS EC2 CentOS
export admin_user='hadoop' # 🔶🔶 AWS EMR
sudo -u $admin_user configurebashrc # non-root (main user)
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


service nginx start
systemctl enable nginx
service nginx status
```

If possible, go to [http://ip_of_the_vm:80] and check the page


#### Configuring Nginx :

`🔵 Debian 11`
<table><tr><td>
   
- No need to touch `/etc/nginx/nginx.conf`
- `vim /etc/nginx/sites-available/default` :
   
a) If you want, you can duplicates those lines and replace 80 by 8080 to duplicate nginx ports
```
listen 80 default_server;
listen [::]:80 default_server;
```
   
b) Add client_max_body_size to fix Jupyterhub bug, and include include location.d folder
```
############## Added by Jean
# Bugfix: 'Request Entity too large' while saving in Jupyterhub
# Source: https://www.cyberciti.biz/faq/linux-unix-bsd-nginx-413-request-entity-too-large/
client_max_body_size 2M;
include /etc/nginx/location.d/*.conf;
################
```
   
- `mkdir /etc/nginx/location.d`
   
</td></tr></table>

`🔴 CentOS` `🟡 RHEL`
<table><tr><td>Please see script</td></tr></table>

#### Generating Home Page :
```bash
chmod +x /var/www/update_index.sh
/var/www/update_index.sh
```
If possible, go to [http://ip_of_the_vm:80] and check the page


### 8. Installing Anaconda (and Jupyter, JupyterLab...)

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
- Think about the Anaconda location. Before, I was enforcing `/opt/anaconda3`. Now I'm keeping default install path `/root/anaconda3`

```bash
filename="Anaconda3-2020.11-Linux-x86_64.sh" # Please update that 
wget -P $tempdir/ https://repo.anaconda.com/archive/$filename
bash $tempdir/$filename # Agree with License, follow the steps...
rm $tempdir/$filename # To be clean (and the installer is big !)
```

#### JupyterHub :
Please see scripts
```bash
anaconda_location="/opt/anaconda3" ./04_jupyterhub/main.sh
usermod -aG jupyterhub_users jlescutmuller
# usermod -aG jupyterhub_users user2... etc..
```

#### JupyterLab :



Palet : 🔴🟠🟡🟢🔵🟣🟤⚫⚪
