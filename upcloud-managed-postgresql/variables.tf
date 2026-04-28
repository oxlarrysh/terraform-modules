variable "configuration_name" {
  type = string
  description = "The name of the configuration, eg. erp-platform"
}

variable "upcloud_username" {
  type = string
  description = "The username of a user that has access to the UpCloud API"
}

variable "upcloud_password" {
  type = string
  description = "The password of a user that has access to the UpCloud API"
}

variable "zone" {
  type = string
  default = "fi-hel2"
  description = "UpCloud zone in which to create the object storage & other resources"
}

variable "plan" {
  type = string
  default = "2x2xCPU-4GB-50GB"
}

variable "database_version" {
  type = string
  description = "PostgreSQL database version"
  default = "13.5"
}

variable "database_username" {
  type = string
  default = "app"
}

variable "allow_ip_addresses" {
  type = list(string)
  description = "Additional IP addresses to have access to the database"
  default = []
}
variable "vault_addr" {
  type = string
  description = "The address of the Vault server"
}

variable "vault_secret_name" {
  type = string
  description = "What to call the secret in Vault"
  default = "production-database-credentials"
}

locals {
  ip_filter = concat(["95.216.176.101", "78.46.208.117"], var.allow_ip_addresses)
}
