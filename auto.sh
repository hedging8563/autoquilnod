#!/bin/bash

# 安装依赖软件
sudo apt-get update
sudo apt-get install git tmux jq -y

# 下载并安装 Go
wget https://go.dev/dl/go1.20.14.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.20.14.linux-amd64.tar.gz

# 配置 Go 环境变量
echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# 安装 Node
tmux new-session -d ' 
cd $HOME # 进入用户主目录
git clone https://github.com/QuilibriumNetwork/ceremonyclient.git # 克隆仓库到本地
cd ceremonyclient/node && GOEXPERIMENT=arenas go run ./... & sleep 180 && pkill go # 进入 node 目录并运行 Go 程序，运行 3 分钟后终止程序
sed -i "s@listenGrpcMultiaddr: \"\"@listenGrpcMultiaddr: /ip4/127.0.0.1/tcp/8337@" .config/config.yml # 替换配置文件中的内容
GOEXPERIMENT=arenas go install ./... # 安装 Go 程序
sudo bash -c 'echo -e "[Unit]\nDescription=Ceremony Client Go App Service\n\n[Service]\nType=simple\nRestart=always\nRestartSec=5s\nWorkingDirectory=/root/ceremonyclient/node\nEnvironment=GOEXPERIMENT=arenas\nExecStart=/root/go/bin/node ./...\n\n[Install]\nWantedBy=multi-user.target" > /lib/systemd/system/ceremonyclient.service' # 创建 Systemd 服务文件
systemctl start ceremonyclient # 启动 Systemd 服务
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest # 安装 grpcurl 工具
service ceremonyclient status # 查看 Node 状态
'
