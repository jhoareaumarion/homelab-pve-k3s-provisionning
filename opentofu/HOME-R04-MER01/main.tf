terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc4"
    }

    netbox = {
      source  = "e-breuninger/netbox"
      version = "3.10.0"
    }
    
    http = {
      source = "hashicorp/http"
      version = "3.4.5"
    }

    bitwarden = {
      source = "maxlaverse/bitwarden"
      version = "0.15.0"
    }
  }
}

module "secrets_module" {
  source                  = "${path.module}/../modules/secrets"
  ## TBD
}
