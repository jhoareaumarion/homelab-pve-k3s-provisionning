terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc04"
    }

    netbox = {
      source  = "e-breuninger/netbox"
      version = "4.2.0"
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

output "master_nodes" {
  value = local.k3s_master_nodes_number
}
output "worker_nodes" {
  value = local.k3s_worker_nodes_number
}