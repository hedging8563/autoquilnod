#!/bin/bash

# Stop the ceremonyclient service
sudo service ceremonyclient stop

# Start a new tmux session named "quil"
tmux new-session -s quil -d

# Change directory and run the script poor_mans_cd.sh in the ceremonyclient/node folder
cd ceremonyclient/node || exit
./poor_mans_cd.sh
