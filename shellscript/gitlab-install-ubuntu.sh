#!/bin/bash

# Install aws cli tool
sudo apt install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install
sleep 2

# Install aws cli tool
sudo apt install -y docker.io
sudo systemctl enable docker
sudo groupadd docker
sudo newgrp docker
sleep 2

# Install Gitlab Runner
curl -LJO "https://gitlab-runner-downloads.s3.amazonaws.com/latest/deb/gitlab-runner_amd64.deb"
sleep 1
sudo dpkg -i gitlab-runner_amd64.deb
sleep 2
sudo systemctl enable gitlab-runner

# Install jq tool
apt install -y jq