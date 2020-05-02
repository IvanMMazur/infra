#!/usr/bin/bash
set -eu

gcloud compute instances create reddit-app \
    --image-family reddit-full-bake \
    --tags puma-server \
    --zone=us-central1-a \
    --restart-on-failure