#!/bin/bash
gcloud compute instances create reddit-app-autourl \
    --boot-disk-size=10GB \
    --image-family ubuntu-1604-lts \
    --image-project=ubuntu-os-cloud \
    --machine-type=g1-small \
    --tags puma-server \
    --zone=us-central1-a \
    --restart-on-failure \
    --metadata=startup-script-url=https://drive.google.com/open?id=10poex4HuOAKy6gO6-Ve9r4cLd5utNtWe