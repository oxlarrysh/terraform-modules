terraform {
  required_version = ">= 0.14.8"
  required_providers {
    upcloud = {
      source = "UpCloudLtd/upcloud"
      version = ">= 2.8.1"
    }
    vault = {
      source = "hashicorp/vault"
      version = ">= 3.1.1"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
  }
}

provider "upcloud" {
  username = var.upcloud_username
  password = var.upcloud_password
}

provider "vault" {
  address = var.vault_addr
}
