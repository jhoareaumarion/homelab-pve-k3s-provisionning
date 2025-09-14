terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.83.0"
    }
    
    http = {
      source = "hashicorp/http"
      version = "3.4.5"
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
  name = "home-desk-r04-mer01-10-mkub-${format("%02d", count.index+1)}"
  description = "Managed by OpenTofu"  
  tags = ["k3s-master-node","opentofu"]

  node_name = "mercury"
  vm_id = 10100 + count.index+1

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
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
    meta_data_file_id = proxmox_virtual_environment_file.master_meta_data_cloud_config[count.index].id
  }
  bios        = "ovmf"  

  serial_device {
  }

  vga {
    type = "serial0"
  }
  efi_disk {
    type = "4m"
    datastore_id = "local-zfs"
  }

  keyboard_layout = "fr"
      
  network_device {
    model  = "virtio"
    bridge = "vmbr0"
    vlan_id = 10
  }
  
  network_device {
    model  = "virtio"
    bridge = "vmbr0"
    vlan_id = 50
  }

  network_device {
    model  = "virtio"
    bridge = "vmbr0"
    vlan_id = 90
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
  name = "home-desk-r04-mer01-10-wkub-${format("%02d", count.index+1)}"
  description = "Managed by OpenTofu"  
  tags = ["k3s-worker-node","opentofu"]

  node_name = "mercury"
  vm_id = 10200 + count.index+1

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
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
    meta_data_file_id = proxmox_virtual_environment_file.worker_meta_data_cloud_config[count.index].id
  }
  bios        = "ovmf"  

  serial_device {
  }

  vga {
    type = "serial0"
  }
  efi_disk {
    type = "4m"
    datastore_id = "local-zfs"
  }

  keyboard_layout = "fr"
      
  network_device {
    model  = "virtio"
    bridge = "vmbr0"
    vlan_id = 10
  }
  
  network_device {
    model  = "virtio"
    bridge = "vmbr0"
    vlan_id = 50
  }

  network_device {
    model  = "virtio"
    bridge = "vmbr0"
    vlan_id = 90
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
}

resource "proxmox_virtual_environment_file" "master_meta_data_cloud_config" {
  count = local.k3s_master_nodes_number
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "mercury"

  source_raw {
    data = <<-EOF
    #cloud-config
    local-hostname: home-desk-r04-mer01-10-mkub-${format("%02d", count.index)}
    EOF

    file_name = "meta-data-cloud-config-master-${format("%02d", count.index)}.yaml"
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
    local-hostname: home-desk-r04-mer01-10-wkub-${format("%02d", count.index)}
    EOF

    file_name = "meta-data-cloud-config-worker-${format("%02d", count.index)}.yaml"
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
    users:
      - default
      - name: ${module.secrets_module.logins["user"].username}
        groups:
          - sudod
        shell: /bin/bash
        ssh_authorized_keys:
          - ${module.secrets_module.ssh_keys["user"].public_key}
        sudo: ALL=(ALL) NOPASSWD:ALL
        passwd: "${sha512(module.secrets_module.logins["user"].password)}"
      - keymap:
        layout: fr   
      - name: ${module.secrets_module.logins["control-node"].username}
        groups:
          - sudod
        shell: /bin/bash
        ssh_authorized_keys:
          - ${module.secrets_module.ssh_keys["control-node"].public_key} 
        sudo: ALL=(ALL) NOPASSWD:ALL
      - keymap:
          layout: fr
    runcmd:
      - |
        cat <<EOT >> /etc/systemd/network/10-ens20.network                  # ens20 is the third interface, connected to the landing VLAN
        [Match]
        Name=ens20

        [Network]
        DHCP=yes
        EOT
      - systemctl restart systemd-networkd
      - apt-get update
      - apt-get install -y qemu-guest-agent
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - echo "done" > /tmp/cloud-config.done    
    output: {all: '| tee -a /var/log/cloud-init-output.log'}
    
    EOF

    file_name = "user-data-cloud-config.yaml"
  }
}