#!/bin/bash

# Update the configuration file
sed -i "s@listenGrpcMultiaddr: \"\"@listenGrpcMultiaddr: /ip4/127.0.0.1/tcp/8337@" ceremonyclient/node/.config/config.yml

# Install grpcurl
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest

# Build and install the Go application
cd ceremonyclient/node
GOEXPERIMENT=arenas /usr/local/go/bin/go install ./...

# Create and start the systemd service
sudo bash -c 'echo -e "[Unit]\nDescription=Ceremony Client Go App Service\n\n[Service]\nType=simple\nRestart=always\nRestartSec=5s\nWorkingDirectory=/root/ceremonyclient/node\nEnvironment=GOEXPERIMENT=arenas\nExecStart=/root/go/bin/node ./...\n\n[Install]\nWantedBy=multi-user.target" > /lib/systemd/system/ceremonyclient.service'
service ceremonyclient start

# Wait for 6 minutes (360 seconds)
sleep 360

# Start a tmux session to monitor service status
tmux new-session -d -s ceremonyclient_session 'service ceremonyclient status'
