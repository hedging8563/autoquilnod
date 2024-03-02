#!/bin/bash

# 安装 jq
sudo apt-get update
sudo apt-get install git tmux jq -y

# 下载和安装 Go
wget https://go.dev/dl/go1.20.14.linux-amd64.tar.gz
sudo tar -xvf go1.20.14.linux-amd64.tar.gz

# 配置 Go 环境变量
echo -e "\nGOROOT=/usr/local/go\nGOPATH=\$HOME/go\nPATH=\$GOPATH/bin:\$GOROOT/bin:\$PATH" >> ~/.bashrc

#载入配置
source ~/.bashrc

# 安装Node

cd $HOME
git clone https://github.com/QuilibriumNetwork/ceremonyclient.git
cd ceremonyclient/node && GOEXPERIMENT=arenas go run ./...
sleep 180s
pkill go
echo "s@listenGrpcMultiaddr: \"\"@listenGrpcMultiaddr: /ip4/127.0.0.1/tcp/8337@" | sed -i'' -f - .config/config.yml
sleep 10s
GOEXPERIMENT=arenas go install ./...
sleep 60s
sudo bash -c '\''echo -e "[Unit]\nDescription=Ceremony Client Go App Service\n\n[Service]\nType=simple\nRestart=always\nRestartSec=5s\nWorkingDirectory=/root/ceremonyclient/node\nEnvironment=GOEXPERIMENT=arenas\nExecStart=/root/go/bin/node ./...\n\n[Install]\nWantedBy=multi-user.target" > /lib/systemd/system/ceremonyclient.service'\'' 
service ceremonyclient start
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
'
