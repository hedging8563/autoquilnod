## Quilibrium Node Installation Scripts

### Installation Step 1
```
curl -sSL https://raw.githubusercontent.com/hedging8563/quilnode/main/auto.sh | bash
```

### Installation Step 2 # With limitation of 720% CPU quota for 8 vCUPs VPS
```
curl -sSL https://raw.githubusercontent.com/hedging8563/quilnode/main/auto2.sh | bash
```

### Update Node
```
curl -sSL https://raw.githubusercontent.com/hedging8563/quilnode/main/update.sh | bash
```

## Backup Config and Keys Files

/root/ceremonyclient/node/.config/config.yml

/root/ceremonyclient/node/.config/keys.yml

## Check $QUIL Balance
cd ~/ceremonyclient/node && GOEXPERIMENT=arenas /root/go/bin/node -balance

## Cat Node Log
sudo journalctl -u ceremonyclient.service -f --no-hostname -o cat

## grpcurl (30 mins after installation)

### Get Node Info (Back up PeerID)
grpcurl -plaintext localhost:8337 quilibrium.node.node.pb.NodeService.GetNodeInfo

### Count of All Quilibrium Nodes
grpcurl -plaintext -max-msg-sz 6000000 localhost:8337 quilibrium.node.node.pb.NodeService.GetPeerInfo | grep peerId | wc -l

### Get All Peer Info
grpcurl -plaintext -max-msg-sz 6000000 localhost:8337 quilibrium.node.node.pb.NodeService.GetPeerInfo | less
