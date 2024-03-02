#!/bin/bash

# Update package lists and install necessary packages
sudo apt-get update
sudo apt-get install -y git tmux jq

# Increase buffer sizes for better network performance
echo -e "\n# Increase buffer sizes for better network performance\nnet.core.rmem_max=600000000\nnet.core.wmem_max=600000000" | sudo tee -a /etc/sysctl.conf > /dev/null
sudo sysctl -p

# Install Go
wget https://go.dev/dl/go1.20.14.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.20.14.linux-amd64.tar.gz

# Append lines to .bashrc if they do not exist
append_if_not_exists() {
    local line_to_append=$1
    local file=$2

    grep -qF -- "$line_to_append" "$file" || echo "$line_to_append" >> "$file"
}

append_if_not_exists 'GOROOT=/usr/local/go' ~/.bashrc
append_if_not_exists 'GOPATH=$HOME/go' ~/.bashrc
append_if_not_exists 'PATH=$GOPATH/bin:$GOROOT/bin:$PATH' ~/.bashrc

source ~/.bashrc

# Clone the repository and run the application
cd $HOME
git clone https://github.com/QuilibriumNetwork/ceremonyclient.git
cd ceremonyclient/node
GOEXPERIMENT=arenas $GOROOT/bin/go run ./...

# Wait for 30 seconds before rebooting
sleep 30
sudo reboot
