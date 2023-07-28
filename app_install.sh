#!/bin/bash

# Install Jenkins
# sudo apt update
# sudo apt install -y openjdk-11-jdk
# curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
#   /usr/share/keyrings/jenkins-keyring.asc > /dev/null
# echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
#   https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
#   /etc/apt/sources.list.d/jenkins.list > /dev/null
# sudo apt-get update
# sudo apt-get install jenkins

# Install Git
sudo apt install -y git

# Install Ansible
sudo apt install -y ansible

# Install Helm
wget https://get.helm.sh/helm-v3.7.1-linux-amd64.tar.gz
tar -zxvf helm-v3.7.1-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/
rm -rf linux-amd64 helm-v3.7.1-linux-amd64.tar.gz

# Install Python
sudo apt install -y python3 python3-pip

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install.


echo "Setup completed!"
