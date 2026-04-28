output "upcloud_managed_database_public_host" {
  value       = local.public_hostname
  description = "Public hostname"
}

output "upcloud_managed_database_public_port" {
  value       = local.public_port
  description = "Public port"
}

output "upcloud_managed_database_admin_username" {
  value       = upcloud_managed_database_postgresql.database.service_username
  description = "Admin username"
}

output "upcloud_managed_database_admin_password" {
  value       = upcloud_managed_database_postgresql.database.service_password
  description = "Admin password"
  sensitive   = true
}
