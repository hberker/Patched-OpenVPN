#!/bin/bash
echo "Installing additional packages..."
sudo -s

apt update
apt upgrade -y

apt-get install gcc rng-tools make automake autoconf dh-autoreconf file patch perl dh-make debhelper devscripts gnupg lintian quilt libtool pkg-config libssl-dev liblzo2-dev libpam0g-dev libpkcs11-helper1-dev openssl liblz4-dev liblz4-tool net-tools iproute2 -y --fix-missing

echo "Complete"
echo "Installing Openvpn"

cd $HOME

wget http://swupdate.openvpn.org/community/releases/openvpn-2.4.6.zip 
 
wget http://swupdate.openvpn.org/community/releases/openvpn-2.4.6.zip 

unzip openvpn-2.4.6.zip 
rm openvpn-2.4.6.zip
cd /$HOME/openvpn-2.4.6/ 

echo "Installing patch"

wget https://raw.githubusercontent.com/Tunnelblick/Tunnelblick/master/third_party/sources/openvpn/openvpn-2.4.6/patches/02-tunnelblick-openvpn_xorpatch-a.diff 

wget https://raw.githubusercontent.com/Tunnelblick/Tunnelblick/master/third_party/sources/openvpn/openvpn-2.4.6/patches/03-tunnelblick-openvpn_xorpatch-b.diff 

wget https://raw.githubusercontent.com/Tunnelblick/Tunnelblick/master/third_party/sources/openvpn/openvpn-2.4.6/patches/04-tunnelblick-openvpn_xorpatch-c.diff 

wget https://raw.githubusercontent.com/Tunnelblick/Tunnelblick/master/third_party/sources/openvpn/openvpn-2.4.6/patches/05-tunnelblick-openvpn_xorpatch-d.diff 

wget https://raw.githubusercontent.com/Tunnelblick/Tunnelblick/master/third_party/sources/openvpn/openvpn-2.4.6/patches/06-tunnelblick-openvpn_xorpatch-e.diff 

echo "Applying"

git apply 02-tunnelblick-openvpn_xorpatch-a.diff
git apply 03-tunnelblick-openvpn_xorpatch-b.diff
git apply 04-tunnelblick-openvpn_xorpatch-c.diff
git apply 05-tunnelblick-openvpn_xorpatch-d.diff
git apply 06-tunnelblick-openvpn_xorpatch-e.diff 

mkdir /etc/openvpn/

echo "Configuring"

cd $HOME/openvpn-2.4.6/ 
autoreconf -i -v -f 
./configure --prefix=/usr 
make 
make install

echo "Installing Obfustication patch"

sudo wget http://downloads.nord4china.com/configs/archives/servers/ovpn_xor.zip 
sudo unzip ovpn_xor.zip 
sudo rm ovpn_xor.zip
