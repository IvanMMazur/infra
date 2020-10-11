#!/bin/bash

# Add keys and repo
ssudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E52529D4
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'

# Install
sudo apt update
sudo apt install -y mongodb-org

# Enable and start service
sudo systemctl start mongod
sudo systemctl enable mongod

# Finaly check service
sudo systemctl status mongod