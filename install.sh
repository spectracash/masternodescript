#!/bin/bash

PORT=22779
RPCPORT=22780
CONF_DIR=~/.scl
COINZIP='https://github.com/spectracash/SCL/releases/download/v1.0/scl-linux.zip'

cd ~
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi

function configure_systemd {
  cat << EOF > /etc/systemd/system/scl.service
[Unit]
Description=SpectraCash Service
After=network.target
[Service]
User=root
Group=root
Type=forking
ExecStart=/usr/local/bin/scld
ExecStop=-/usr/local/bin/scl-cli stop
Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5
[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
  sleep 2
  systemctl enable scl.service
  systemctl start scl.service
}

echo ""
echo ""
DOSETUP="y"

if [ $DOSETUP = "y" ]  
then
  apt-get update
  apt install zip unzip git curl wget -y
  cd /usr/local/bin/
  wget $COINZIP
  unzip *.zip
  rm scl-qt scl-tx scl-linux.zip
  chmod +x scl*
  
  mkdir -p $CONF_DIR
  cd $CONF_DIR

fi

 IP=$(curl -s4 api.ipify.org)
 echo ""
 echo "Configure your masternodes now!"
 echo "Detecting IP address:$IP"
 echo ""
 echo "Enter masternode private key"
 read PRIVKEY
 
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> scl.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> scl.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> scl.conf_TEMP
  echo "rpcport=$RPCPORT" >> scl.conf_TEMP
  echo "listen=1" >> scl.conf_TEMP
  echo "server=1" >> scl.conf_TEMP
  echo "daemon=1" >> scl.conf_TEMP
  echo "maxconnections=250" >> scl.conf_TEMP
  echo "masternode=1" >> scl.conf_TEMP
  echo "" >> scl.conf_TEMP
  echo "port=$PORT" >> scl.conf_TEMP
  echo "externalip=$IP:$PORT" >> scl.conf_TEMP
  echo "masternodeaddr=$IP:$PORT" >> scl.conf_TEMP
  echo "masternodeprivkey=$PRIVKEY" >> scl.conf_TEMP
  mv scl.conf_TEMP scl.conf
  cd
  echo ""
  echo -e "Your ip is ${GREEN}$IP:$PORT${NC}"

	## Config Systemctl
	configure_systemd
  
echo ""
echo "Commands:"
echo -e "Start SpectraCash Service: ${GREEN}systemctl start scl${NC}"
echo -e "Check SpectraCash Status Service: ${GREEN}systemctl status scl${NC}"
echo -e "Stop SpectraCash Service: ${GREEN}systemctl stop scl${NC}"
echo -e "Check Masternode Status: ${GREEN}scl-cli getmasternodestatus${NC}"

echo ""
echo -e "${GREEN}SpectraCash Masternode Installation Done${NC}"
exec bash
exit
