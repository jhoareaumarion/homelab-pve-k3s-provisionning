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
- `Ansible` inventory shall be made using `PVE` and `Netbox` 
- `Ansible` will be used to connect to the newly created VMs and setting up the required config (hardening + K3s installation)
- Changes will be reflected on my `Netbox` instance
