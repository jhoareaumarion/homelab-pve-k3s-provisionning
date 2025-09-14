# Homelab PVE-K3s Provisioning with Ansible

This repository contains Ansible playbooks and roles for provisioning and managing Proxmox VE (PVE) virtual machines and integrating them with NetBox for inventory management.

---

## Repository Structure
```
├── ansible.cfg
├── hooks/
│   ├── manage-sensitive-vars.sh                            # To encrypt/decrypt all sensitive yml files in the repository
│   └── vault-password                                      # The plain-text vault password
├── inventory/
│   ├── home-desk-r04-mer01.proxmox.yml                     
│   └── netbox.yml        
├── push-k3s-to-netbox.yml
├── roles/
│   └── manage-netbox/
│       ├── README.md
│       ├── defaults/
│       │   └── main.yml
│       ├── files/
│       ├── handlers/
│       │   └── main.yml
│       ├── meta/
│       │   └── main.yml
│       ├── tasks/
│       │   ├── create-disks.yml
│       │   ├── create-interfaces.yml
│       │   └── main.yml
│       ├── templates/
│       ├── tests/
│       │   ├── inventory/
│       │   └── test.yml
│       └── vars/
│           └── main.yml
└── secrets.yml                                             # Required secrets to fetch
```


## Inventories
- home-desk-r04-mer01.proxmox.yml = [Proxmox Inventory Module](https://docs.ansible.com/ansible/latest/collections/community/proxmox/proxmox_inventory.html#ansible-collections-community-proxmox-proxmox-inventory)
- netbox.yml = [Netbox Inventory Module](https://docs.ansible.com/ansible/latest/collections/netbox/netbox/nb_inventory_inventory.html)
- Automatically included in any ansible commands (see file `ansible/ansible.cfg`)
## Playbooks

### initialize-k3s-into-homelab.yml

#### Recap
Based on the Proxmox node `home-desk-r04-mer01` represented by the inventory `home-desk-r04-mer01.proxmox.yml` :
- It creates all VMs as specified in the opentofu state
- Then for each VM
    - creates its interfaces, considering interface #1 = VLAN 10, interface #2 = VLAN 50 and interface #3 = VLAN 90
    - assigns IP from related IP prefixes on Netbox 
    - update the `Kea` DHCPv4 reservations accordingly

This playbook shall be used once the tofu plan at `opentofu/HOME-DESK-R04-MER01` has been applied successfully 
#### Example of use
`ansible-playbook initialize-k3s-into-homelab.yml`