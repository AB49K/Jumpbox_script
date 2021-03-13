#First we set up an openvpn3 client
#Script only works for Centos7
read -p 'New Hostname for machine (must be all lowercase eg "jump.clientname.6162s.net": ' hostname
hostname $hostname
echo $hostname > /etc/hostname
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
yum install yum-plugin-copr -y
yum copr enable dsommers/openvpn3 -y
yum install openvpn3-client -y
openvpn3 session-start --config Jump_Network.ovpn
echo 'nameserver 10.0.10.1' > /etc/resolv.conf
yum install realmd ipa-client oddjob oddjob-mkhomedir sssd -y
read -p 'Joining the domain (Must domain admin) Username: ' dadmin
realm join -v auth.6162s.net -U $dadmin
yum install cockpit NetworkManager -y
yum groupinstall "GNOME Desktop" "Graphical Administration Tools" -y
yum groupinstall -y "Xfce"
yum install xrdp tigervnc-server -y
mv sesman.ini /etc/xrdp/sesman.ini
systemctl start xrdp
systemctl start cockpit
read -p 'Configuring firewall. Please enter WAN interface (usually eth0) : ' interface
firewall-cmd --zone=public --add-source=10.0.8.0/24 --permanent
firewall-cmd --zone=public --add-source=10.0.9.0/24 --permanent
firewall-cmd --zone=home --change-interface=$interface
firewall-cmd --zone=public --add-port=3389/tcp
firewall-cmd --zone=public --add-port=9090/tcp
firewall-cmd --reload
echo 'Setup Complete, Auditors may now log in with RDP and install their own software'

