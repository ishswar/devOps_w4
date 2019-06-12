#!/bin/bash

hostname


echo "Host IP address : $host_ip"

echo "############# Install GNOME GUI ##############"
printf "\n"
echo "##############################################"

sudo yum groupinstall "GNOME Desktop" -y
systemctl set-default graphical.target


echo "############ Installing tigerVNC Server ######## "
printf "\n"
echo "##############################################"
sudo yum install -y tigervnc-server xorg-x11-fonts-Type1

id 

echo "############ Adding password to tigerVNC Server ###"
printf "\n"
echo "###################################################"

runuser -l vagrant -c 'printf "vagrant\nvagrant\n" >> ~/password.txt'

runuser -l vagrant -c 'cat ~/password.txt | vncpasswd'

#runuser -l vagrant -c 'printf "vagrant\nvagrant\nn" >> ~/password2.txt'

#runuser -l vagrant -c 'cat ~/password2.txt | vncserver'

#runuser -l vagrant -c "sed 's/vncserver/#vncserver/' /home/vagrant/.vnc/xstartup >> /home/vagrant/.vnc/xstartup_tmp"

#runuser -l vagrant -c "rm -rf /home/vagrant/.vnc/xstartup"

#runuser -l vagrant -c "cp /home/vagrant/.vnc/xstartup_tmp /home/vagrant/.vnc/xstartup"

echo "############ Becoming root tigerVNC Server "
printf "\n"
echo "##############################################"

sudo -s 

ss -tulpn| grep vnc

echo "############ Disabling firewall for tigerVNC Server "
printf "\n"
echo "##############################################"
systemctl disable firewalld.service
systemctl is-enabled firewalld

echo "############ Updating file vncserver@:1.service for tigerVNC Server "
printf "\n"
echo "##############################################"
cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service
sed 's/<USER>/vagrant/' /etc/systemd/system/vncserver@:1.service >> /etc/systemd/system/vncserver@:1.service_tmp
rm -rf /etc/systemd/system/vncserver@:1.service
mv /etc/systemd/system/vncserver@:1.service_tmp /etc/systemd/system/vncserver@:1.service
cat /etc/systemd/system/vncserver@:1.service

echo "############ Starting VNC Server #############"
printf "\n"
echo "##############################################"

systemctl daemon-reload
systemctl start vncserver@:1
systemctl status vncserver@:1

ss -tulpn| grep vnc
sleep 10
echo "############ Upating Config of VNC Server ####"
printf "\n"
echo "##############################################"

runuser -l vagrant -c "sed 's/vncserver/#vncserver/' /home/vagrant/.vnc/xstartup >> /home/vagrant/.vnc/xstartup_tmp"

runuser -l vagrant -c "rm -rf /home/vagrant/.vnc/xstartup"

runuser -l vagrant -c "cp /home/vagrant/.vnc/xstartup_tmp /home/vagrant/.vnc/xstartup"

runuser -l vagrant -c "chmod 775 /home/vagrant/.vnc/xstartup"

sleep 10
echo "############ Re-Starting VNC Server #############"
printf "\n"
echo "#################################################"

systemctl start vncserver@:1
systemctl status vncserver@:1

# ss -tulpn| grep vnc

systemctl enable vncserver@:1

ss -tulpn| grep vnc


#########
#Install Python 2.7.10 on CentOS/RHEL
#########

echo "############# Install Python 2.7.10 ##############"
printf "\n"
echo "##################################################"
yum install gcc

cd /usr/src
wget https://www.python.org/ftp/python/2.7.10/Python-2.7.10.tgz

tar xzf Python-2.7.10.tgz
cd Python-2.7.10
./configure
make altinstall

python2.7 -V

#############
### Install Apache Web Server
#############

yum -y update
yum -y install httpd

systemctl start httpd
systemctl enable httpd
systemctl status httpd

firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload

####
## Check Apache Web Server - accesible from outside the VM
###

echo "Host IP address : $host_ip"
# 8045 is port that is exposed on Guest 
# host_ip is IP of guest 
# below command will check if we can access apache from outside of VM 
wget http://$host_ip:8045/images/apache_pb.gif

sudo yum -y install tigervnc-server
