terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.93.0"
    }
    
    http = {
      source = "hashicorp/http"
      version = "3.5.0"
    }    

    time = {
      source = "hashicorp/time"
      version = "0.13.1"
    }
  }
}

module "secrets_module" {
  source                  = "${path.module}/../modules/secrets"  
  master_password = var.master_password
  client_id       = var.client_id
  client_secret   = var.client_secret
  server          = var.server
  ssh_key_names   = var.ssh_key_names
  login_names     = var.login_names
}

locals{
  api_key = [
    for f in module.secrets_module.logins["netbox"].field : f
    if f.name == "api-key"
  ][0].hidden # Get the first match
  netbox_url = module.secrets_module.logins["netbox"].uri[0].value
  host = jsondecode(data.http.get_host.response_body).results[0]
  k3s_master_nodes_number = local.host.custom_fields.k3s_master_nodes_number
  k3s_worker_nodes_number = local.host.custom_fields.k3s_worker_nodes_number
}

data "http" "get_host" {
  url = "${local.netbox_url}/api/dcim/devices/?name=HOME-DESK-R04-MER01"

  request_headers = {
    Accept = "application/json"
    Authorization = "Token ${local.api_key}"
  }
}

resource "proxmox_virtual_environment_vm" "k3s_master_nodes" {
  count = local.k3s_master_nodes_number
  name = "home-desk-r04-mer01-20-mkub-${format("%02d", count.index+1)}"
  description = "Managed by OpenTofu"  
  tags = ["k3s-master-node","opentofu","k3s-master-node-init"]

  node_name = "mercury"
  vm_id = 20100 + count.index+1

  cpu {
    cores      = 2
    sockets    = 1
    type       = "x86-64-v2-AES"
  }
  
  memory     {
    dedicated = 2048
    floating = 2048
  }

  disk {
    datastore_id  = "local-zfs"
    import_from = proxmox_virtual_environment_download_file.cloud_image.id
    interface = "scsi0"
    iothread = true
    backup = true
    discard = "on"
    size     = 3
  }

  initialization {
    datastore_id = "local-zfs"
    interface = "ide2"
    network_data_file_id = proxmox_virtual_environment_file.network_data_config.id
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
    meta_data_file_id = proxmox_virtual_environment_file.master_meta_data_cloud_config[count.index].id
  }
  bios        = "ovmf"  

  vga {
    type = "virtio"
  }
  efi_disk {
    type = "4m"
    datastore_id = "local-zfs"
  }

  keyboard_layout = "fr"
      
  network_device {
    model  = "virtio"
    bridge = "vmbr0"
    mac_address = "${local.host.config_context.cluster_base_mac_address}:${local.host.config_context.master_mac_address_octet}:${format("%02d", count.index+1)}"
  }

  dynamic "network_device" {
      for_each = var.master_node_temporary_interface[count.index]  ? [1] : []
      content {
        model   = "virtio"
        bridge  = "vmbr0"
        vlan_id = 90
      }
  }

  operating_system {
    type = "l26"
  }
  on_boot = true
  scsi_hardware     = "virtio-scsi-single"
  started = true
  agent {
    enabled = true
    type    = "virtio" 
  }
  boot_order = ["virtio0"]
  stop_on_destroy = true

  lifecycle {
    ignore_changes = [ 
    ]
  }
}

resource "proxmox_virtual_environment_vm" "k3s_worker_nodes" {
  count = local.k3s_worker_nodes_number
  name = "home-desk-r04-mer01-20-wkub-${format("%02d", count.index+1)}"
  description = "Managed by OpenTofu"  
  tags = ["k3s-worker-node","opentofu","k3s-worker-node-init"]

  node_name = "mercury"
  vm_id = 20200 + count.index+1

  cpu {
    cores      = 2
    sockets    = 1
    type       = "x86-64-v2-AES"
  }
  
  memory     {
    dedicated = 2048
    floating = 2048
  }

  disk {
    datastore_id  = "local-zfs"
    import_from = proxmox_virtual_environment_download_file.cloud_image.id
    interface = "scsi0"
    iothread = true
    backup = true
    discard = "on"
    size     = 3
  }

  initialization {
    datastore_id = "local-zfs"
    interface = "ide2"
    network_data_file_id = proxmox_virtual_environment_file.network_data_config.id
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
    meta_data_file_id = proxmox_virtual_environment_file.worker_meta_data_cloud_config[count.index].id
  }
  bios        = "ovmf"  


  vga {
    type = "virtio"
  }
  efi_disk {
    type = "4m"
    datastore_id = "local-zfs"
  }

  keyboard_layout = "fr"
      
  network_device {
    model  = "virtio"
    bridge = "vmbr0"
    mac_address = "${local.host.config_context.cluster_base_mac_address}:${local.host.config_context.worker_mac_address_octet}:${format("%02d", count.index+1)}"
  }

  operating_system {
    type = "l26"
  }
  on_boot = true
  scsi_hardware     = "virtio-scsi-single"
  started = true
  agent {
    enabled = true
    type    = "virtio" 
  }
  boot_order = ["virtio0"]
  stop_on_destroy = true

  lifecycle {
    ignore_changes = [ 
    ]
  }
}

resource "proxmox_virtual_environment_download_file" "cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = "mercury"
  url          = module.secrets_module.logins["ci"].uri[0].value
  file_name = [
    for f in module.secrets_module.logins["ci"].field : f
    if f.name == "file-name"
  ][0].text 
  overwrite     = true
}

resource "proxmox_virtual_environment_file" "master_meta_data_cloud_config" {
  count = local.k3s_master_nodes_number
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "mercury"

  source_raw {
    data = <<-EOF
    #cloud-config
    local-hostname: home-desk-r04-mer01-20-mkub-${format("%02d", count.index+1)}
    EOF

    file_name = "meta-data-cloud-config-master-${format("%02d", count.index+1)}"
  }
}

resource "proxmox_virtual_environment_file" "worker_meta_data_cloud_config" {
  count = local.k3s_worker_nodes_number
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "mercury"

  source_raw {
    data = <<-EOF
    #cloud-config
    local-hostname: home-desk-r04-mer01-20-wkub-${format("%02d", count.index+1)}
    EOF

    file_name = "meta-data-cloud-config-worker-${format("%02d", count.index+1)}"
  }
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "mercury"

  source_raw {
    data = <<-EOF
    #cloud-config
    timezone: Europe/Paris
    chpasswd:
      users:
        - name: ${module.secrets_module.logins["user"].username}
          password: ${module.secrets_module.logins["user"].password}
          type: text
      expire: false
    users:
      - default
      - name: ${module.secrets_module.logins["user"].username}
        groups:
          - sudod
        shell: /bin/bash
        ssh_authorized_keys:
          - ${module.secrets_module.ssh_keys["user"].public_key}
        sudo: ALL=(ALL) NOPASSWD:ALL
      - name: ${module.secrets_module.logins["control-node"].username}
        groups:
          - sudod
        shell: /bin/bash
        ssh_authorized_keys:
          - ${module.secrets_module.ssh_keys["control-node"].public_key}
        sudo: ALL=(ALL) NOPASSWD:ALL
    keyboard:
      layout: fr
    bootcmd:
      - rm -f /sbin/crda
      - apt-get purge -y crda wireless-regdb
    runcmd:
      - systemctl restart systemd-networkd
      - apt update
      - apt install -y qemu-guest-agent
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - echo "done" > /tmp/cloud-config.done
    output: {all: '| tee -a /var/log/cloud-init-output.log'}
    EOF

    file_name = "user-data"
  }
}

resource "proxmox_virtual_environment_file" "network_data_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "mercury"

  source_raw {
    data = <<-EOF
#cloud-config
network:
  version: 2
  ethernets:
    ens18:
      match:
        name: ens18
      dhcp4: no
      link-local: []
  vlans:
    ens18.20:
      id: 20
      link: ens18
      dhcp4: yes
      dhcp4-overrides:
        route-metric: 100
      link-local: []
    ens18.50:
      id: 50
      link: ens18
      dhcp4: no
      link-local: []
    ens18.60:
      id: 60
      link: ens18
      dhcp4: no
      link-local: []
  renderer: networkd
EOF
    file_name = "network-config"
  }
}

resource "null_resource" "attach_physical_disk_to_homelab_nas_playbook" {
  count = local.vm.status.value == "staged" ? 1 : 0
  
  provisioner "local-exec" {
    command = <<-EOF
    ansible-playbook ../../ansible/initialize-k3s-into-homelab.yml \
    EOF
    environment = {
      ANSIBLE_FORCE_COLOR = "true"
      ANSIBLE_TIMEOUT     = "120"
      ANSIBLE_CONFIG      = "../../ansible/ansible.cfg"
      BW_SESSION          = "redacted"
    }
  }
  depends_on = [proxmox_virtual_environment_vm.home-desk-r01-jup01-50-tnas01]
}