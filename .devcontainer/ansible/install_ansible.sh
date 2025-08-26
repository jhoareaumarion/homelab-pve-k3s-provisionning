#!/bin/bash
set -euo pipefail

# Update package lists and install pipx
python3 -m pip install --user pipx
python3 -m pipx ensurepath

# Ensure pipx is in the PATH
pipx ensurepath
pipx ensurepath --global # optional to allow pipx actions with --global argument

# Install Ansible via pipx (including dependencies)
pipx install --include-deps ansible

# Install ansible-lint via pipx
pipx install ansible-lint