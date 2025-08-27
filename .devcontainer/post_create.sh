#!/bin/bash
set -e

if [ ! -z "$PYTHON_PACKAGES" ]; then
    echo "Injecting Python packages into pipx Ansible environment..."
    pipx inject ansible $(echo $PYTHON_PACKAGES | tr ',' ' ')
fi

if [ ! -z "$ANSIBLE_COLLECTIONS" ]; then
    echo "Installing Ansible collections..."
    echo "collections:" > /tmp/requirements.yml
    for c in ${ANSIBLE_COLLECTIONS//,/ }; do
        echo "  - name: $c" >> /tmp/requirements.yml
    done
    ansible-galaxy collection install -r /tmp/requirements.yml
fi

if [ ! -z "$SNAP_PACKAGES" ]; then
    echo "Installing snap packages into the devcontainer.."
    snap install $(echo $SNAP_PACKAGES | tr ',' ' ')
fi

# Cleanup environment variables
unset PYTHON_PACKAGES
unset ANSIBLE_COLLECTIONS
unset SNAP_PACKAGES