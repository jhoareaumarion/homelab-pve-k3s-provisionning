provider "proxmox" {
  endpoint          = local.pve_endpoint
  api_token         = local.pve_api_token
  username = module.secrets_module.logins["mercury"].username
  ssh {
    agent    = true
    username = module.secrets_module.logins["mercury"].username
    private_key = module.secrets_module.ssh_keys["opentofu"].private_key
    node {
      name = "mercury"
      address = "10.10.10.4"
    }
  }
}

locals{
  pve_endpoint = module.secrets_module.logins["mercury"].uri[0].value
  pve_api_token = [
    for f in module.secrets_module.logins["mercury"].field : f
    if f.name == "api-token"
  ][0].hidden 
}
