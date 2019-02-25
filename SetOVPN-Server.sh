#!/bin/bash
sudo -s
cd $HOME/openvpn-2.4.6

wget --no-check-cert https://www.dropbox.com/s/nz4dyons6tlsbr4/etcinitdopenvpn.sh -O /etc/init.d/openvpn
chmod +x /etc/init.d/openvpn
update-rc.d openvpn defaults

mkdir $HOME/clientside
mkdir $HOME/serverside
cd $HOME/serverside
wget https://github.com/OpenVPN/easy-rsa/archive/master.zip
unzip master.zip

cd easy-rsa-master/easyrsa3

echo "Building keys"

openvpn --genkey --secret ta.key
./easyrsa init-pki
./easyrsa --batch build-ca nopass
./easyrsa --batch build-server-full server nopass
./easyrsa --batch build-client-full client1 nopass
./easyrsa gen-dh

cp $HOME/serverside/easy-rsa-master/easyrsa3/pki/ca.crt $HOME/serverside/
cp $HOME/serverside/easy-rsa-master/easyrsa3/pki/issued/server.crt $HOME/serverside/
cp $HOME/serverside/easy-rsa-master/easyrsa3/pki/dh.pem $HOME/serverside/dh2048.pem
cp $HOME/serverside/easy-rsa-master/easyrsa3/pki/private/server.key $HOME/serverside/
cp $HOME/serverside/easy-rsa-master/easyrsa3/ta.key $HOME/serverside/
cp $HOME/serverside/easy-rsa-master/easyrsa3/pki/issued/client1.crt $HOME/clientside/
cp $HOME/serverside/easy-rsa-master/easyrsa3/ta.key $HOME/clientside/
cp $HOME/serverside/easy-rsa-master/easyrsa3/pki/ca.crt $HOME/clientside/
cp $HOME/serverside/easy-rsa-master/easyrsa3/pki/private/client1.key $HOME/clientside/

cd $HOME/clientside/

echo "client
dev tun
proto udp
scramble obfuscate test
remote change_this_to_server_address 34557
resolv-retry infinite
nobind
persist-key
persist-tun
sndbuf 0
rcvbuf 0
ca ca.crt
cert client1.crt
key client1.key
tls-auth ta.key 1
remote-cert-tls server
cipher AES-256-CBC
comp-lzo
verb 3" > raspberrypi.ovpn

wget --no-check-cert https://www.dropbox.com/s/v228zvccef9d10c/merge.sh -O merge.sh
sudo chmod +x merge.sh
sudo ./merge.sh
sudo chown $USER $HOME/clientside/raspberrypi.ovpn

cd $HOME/serverside/

echo "port 34557
proto udp
scramble obfuscate test
dev tun
ca ca.crt
cert server.crt
key server.key
tls-auth ta.key 0
dh dh2048.pem
sndbuf 0
rcvbuf 0
chroot /etc/openvpn/jail
server 10.8.0.0 255.255.255.0
cipher AES-256-CBC
comp-lzo
persist-key
persist-tun
user nobody
group nogroup
status /etc/openvpn/openvpn-status.log
verb 3
push \"redirect-gateway def1\"
push \"dhcp-option DNS 208.67.222.222\"
push \"dhcp-option DNS 208.67.220.220\"
keepalive 5 30" > server.conf

cd $HOME/serverside/
wget --no-check-cert https://www.dropbox.com/s/9wc3we8ezfucj1j/merge_server.sh -O merge_server.sh
sudo chmod +x merge_server.sh
sudo ./merge_server.sh

sudo cp $HOME/serverside/server.conf /etc/openvpn/
sudo mkdir /etc/openvpn/jail/
sudo mkdir /etc/openvpn/jail/tmp/

echo "Set net.ipv4.ip_forward=1 by removing the '#'"
sleep 2
sudo nano /etc/sysctl.conf

echo "Set IP-Tables see readme to set last line use ifconfig and get the line net to inet on the connected interface"
sleep 3
ifconfig
sleep 7
echo "#!/bin/bash
iptables -t filter -F
iptables -t nat -F
#iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-port 34557
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -s “10.8.0.1/24” -j ACCEPT
#iptables -A FORWARD -j REJECT
iptables -t nat -A POSTROUTING -s “10.8.0.1/24” -j MASQUERADE
#iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-port 34557
#iptables -I INPUT -p udp --dport 53 -j ACCEPT
iptables -t nat -A PREROUTING -p udp -d [IP ADDRESS] -i [WIFI INTERFACE(probably eth0)] --dport 53 -j REDIRECT --to-port 34557" > /usr/local/bin/firewall.sh

sudo chmod +x /usr/local/bin/firewall.sh
sudo nano /usr/local/bin/firewall.sh
sudo /usr/local/bin/firewall.sh

echo "Rebooting"
sleep 1
sudo reboot


