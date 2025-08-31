# Configure the Bitwarden Provider
provider "bitwarden" {
  master_password = var.master_password
  client_id       = var.client_id
  client_secret   = var.client_secret
  server          = var.server
}