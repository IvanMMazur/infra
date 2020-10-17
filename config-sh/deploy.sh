#!/bin/bash
cd ~

# Download and make
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install

# Start service and check
puma -d
ps aux | grep puma