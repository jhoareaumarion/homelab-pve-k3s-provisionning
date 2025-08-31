output "logins" {
  value = data.bitwarden_item_login.logins
}

output "ssh_keys" {
  value = data.bitwarden_item_ssh_key.ssh_keys
}