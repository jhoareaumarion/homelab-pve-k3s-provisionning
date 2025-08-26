#!/bin/bash
set -euo pipefail

# Installing required packages to install OpenTofu
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg

# Create keyring directory
install -m 0755 -d /etc/apt/keyrings

# Download GPG keys
wget -qO- https://get.opentofu.org/opentofu.gpg | tee /etc/apt/keyrings/opentofu.gpg >/dev/null
wget -qO- https://packages.opentofu.org/opentofu/tofu/gpgkey | gpg --no-tty --batch --dearmor -o /etc/apt/keyrings/opentofu-repo.gpg

# Add OpenTofu repository
cat <<EOF | tee /etc/apt/sources.list.d/opentofu.list >/dev/null
deb [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main
deb-src [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main
EOF

# Set proper permissions
chmod a+r /etc/apt/sources.list.d/opentofu.list
apt-get update
apt-get install -y tofu