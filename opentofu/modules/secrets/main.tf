terraform {
    required_providers {      
        bitwarden = {
            source = "maxlaverse/bitwarden"
            version = "0.16.0"
        }
    }
}

data "bitwarden_item_ssh_key" "ssh_keys" {
  for_each = var.ssh_key_names
  id = each.value
}

data "bitwarden_item_login" "logins" {
  for_each = var.login_names
  id = each.value
}