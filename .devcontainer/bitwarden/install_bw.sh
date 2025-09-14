#!/bin/bash

# Download the ZIP file
wget "https://vault.bitwarden.com/download/?app=cli&platform=linux" -O bitwarden-cli.zip
apt-get install -y ./bitwarden-cli.zip
# Unzip the file
unzip bitwarden-cli.zip -d /tmp/bitwarden
mv /tmp/bitwarden/bw /usr/local/bin

rm bitwarden-cli.zip