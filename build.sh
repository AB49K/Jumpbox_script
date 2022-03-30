#!/bin/bash

#Please note this script has been modified to change network IP/names for security concerns.

#Script only works for Centos7


#Needs to have a compliant hostname set
read -p 'New Hostname for machine (must be all lowercase eg "clientname.example.net": ' hostname
hostname $hostname
echo $hostname > /etc/hostname

#Installing openvpn3 and connecting to the jump-box network
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
yum install yum-plugin-copr -y
yum copr enable dsommers/openvpn3 -y
yum install openvpn3-client -y
openvpn3 session-start --config Jump_Network.ovpn

#Adding the internal DNS resolver and joining the domain
echo "10.0.9.2  auth.example.net" >> /etc/hosts
yum install realmd ipa-client oddjob oddjob-mkhomedir sssd -y
read -p 'Joining the domain (Must domain admin) Username: ' dadmin
realm join -v auth.example.net -U $dadmin

#Installing access software and fixing up some by-default broken xrdp configs
yum install cockpit NetworkManager -y
yum groupinstall "GNOME Desktop" "Graphical Administration Tools" -y
yum groupinstall -y "Xfce"
yum install xrdp tigervnc-server -y
#Always copy files. Moving them can cause SELinux issues.
cp sesman.ini /etc/xrdp/sesman.ini
cp .Xclients /etc/skel/.
chmod +x /etc/skel/.Xclients
systemctl start xrdp
systemctl start cockpit

#Firewall configs - Not working right just yet.
read -p 'Configuring firewall. Please enter WAN interface (usually eth0) : ' interface
firewall-cmd --zone=public --add-source=10.0.9.0/24 --permanent
firewall-cmd --zone=public --add-source=10.0.8.0/24 --permanent
firewall-cmd --zone=home --change-interface=$interface
firewall-cmd --zone=public --add-port=3389/tcp
firewall-cmd --zone=public --add-port=9090/tcp
firewall-cmd --reload
echo 'Setup Complete, Auditors may now log in with RDP and install their own software'

