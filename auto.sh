#!/bin/bash

sudo apt-get update
sudo apt-get install git tmux jq -y

wget https://go.dev/dl/go1.20.14.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.20.14.linux-amd64.tar.gz

echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

cd $HOME
git clone https://github.com/QuilibriumNetwork/ceremonyclient.git
cd ceremonyclient/node && GOEXPERIMENT=arenas go run ./... & sleep 180 && pkill -f "GOEXPERIMENT=arenas go run ./..."

sed -i "s@listenGrpcMultiaddr: \"\"@listenGrpcMultiaddr: /ip4/127.0.0.1/tcp/8337@" .config/config.yml
GOEXPERIMENT=arenas go install ./...
sudo bash -c 'echo -e "[Unit]\nDescription=Ceremony Client Go App Service\n\n[Service]\nType=simple\nRestart=always\nRestartSec=5s\nWorkingDirectory=/root/ceremonyclient/node\nEnvironment=GOEXPERIMENT=arenas\nExecStart=/root/go/bin/node ./...\n\n[Install]\nWantedBy=multi-user.target" > /lib/systemd/system/ceremonyclient.service'
systemctl start ceremonyclient
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
service ceremonyclient status
