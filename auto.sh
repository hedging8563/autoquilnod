# Function to append line to file if not already present
append_if_not_exists() {
    local line_to_append=$1
    local file=$2

    grep -qF -- "$line_to_append" "$file" || echo "$line_to_append" >> "$file"
}

sudo apt-get update
sudo apt-get install git jq -y

wget https://go.dev/dl/go1.20.14.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.20.14.linux-amd64.tar.gz

# Append lines to .bashrc if they do not exist
append_if_not_exists 'GOROOT=/usr/local/go' ~/.bashrc
append_if_not_exists 'GOPATH=$HOME/go' ~/.bashrc
append_if_not_exists 'PATH=$GOPATH/bin:$GOROOT/bin:$PATH' ~/.bashrc

source ~/.bashrc

cd $HOME
git clone https://github.com/QuilibriumNetwork/ceremonyclient.git
cd ceremonyclient/node && GOEXPERIMENT=arenas go run ./... &
GO_PID=$!
sleep 180

# Try multiple times to terminate the process until successful
for i in {1..5}; do
    pkill -P $GO_PID
    sleep 5
done

if ps -p $GO_PID > /dev/null; then
    echo "Process still running, force killing..."
    kill -9 $GO_PID
fi

sed -i "s@listenGrpcMultiaddr: \"\"@listenGrpcMultiaddr: /ip4/127.0.0.1/tcp/8337@" .config/config.yml
GOEXPERIMENT=arenas go install ./...
sudo bash -c 'echo -e "[Unit]\nDescription=Ceremony Client Go App Service\n\n[Service]\nType=simple\nRestart=always\nRestartSec=5s\nWorkingDirectory=/root/ceremonyclient/node\nEnvironment=GOEXPERIMENT=arenas\nExecStart=/root/go/bin/node ./...\n\n[Install]\nWantedBy=multi-user.target" > /lib/systemd/system/ceremonyclient.service'
systemctl start ceremonyclient
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
service ceremonyclient status
