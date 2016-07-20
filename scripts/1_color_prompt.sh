cp /root/.bashrc /root/.bashrc-backup
cp /home/$USERNAME/.bashrc /home/$USERNAME/.bashrc-backup

sed -i '/^#force_color_prompt=yes/s/^#//' /root/.bashrc
sed -i '/^#force_color_prompt=yes/s/^#//' /home/$USERNAME/.bashrc

# Change the root prompt in red (32m --> 31m)
sed -i '/PS1=.*\[01;32m\\\]\\u/s/32m/31m/' /root/.bashrc
# For color codes : https://ubuntulife.files.wordpress.com/2011/04/bashcolor.png
