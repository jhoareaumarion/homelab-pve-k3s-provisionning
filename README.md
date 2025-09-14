# Proxmox VE - K3S Provisionning
This repository contains my current implementation of OpenTofu/Ansible to provision a working K3S VM set on my Proxmox VE Node.

## 🚀 Getting Started

### Devcontainer setup
Render my devcontainer template using the command below from my WSL instance that includes [Dev Container CLI](https://github.com/devcontainers/cli)r: 
```bash
devcontainer templates apply --workspace-folder ../homelab-pve-k3s-provisionning --template-id ghcr.io/jhoareaumarion/devcontainers/ansible-kubernetes-tofu:latest --template-args '{ "additionnalAnsibleCollect
ions":"netbox.netbox", "additionalPythonPackages":"pynetbox" }'
```

### Requirements
- `Netbox` will tell me how many masters/workers are required on this node.
- `OpenTofu` will populate the required VMs on the node
- `Ansible` will update Netbox accordingly
- `Ansible` inventory shall be made using `PVE` and `Netbox` 
- `Ansible` will be used to connect to the newly created VMs and setting up the required config (hardening + K3s installation)
- Changes will be reflected on my `Netbox` instance

### How to use
- Set the postgreSQL backend credential to PG_CONN_STR environment variable
- From the device folder (e.g. opentofu/HOME-DESK-R04-MER01), run the command `tofu apply -var-file="../common/bitwarden_provider.tfvars"`
- Connect to bitwarden using `bw` CLI
    - bw config server **BITWARDEN_SERVER**
    - bw login --raw (to get session id) OR bw unlock
    - export BW_SESSION="{{ the session id from above }}"