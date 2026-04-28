resource "upcloud_managed_database_postgresql" "database" {
  name  = "app-${var.configuration_name}"
  title = "app ${var.configuration_name}"
  plan  = var.plan
  zone  = var.zone

  properties {
    ip_filter                = local.ip_filter
    pg_stat_monitor_enable   = true
    pg_stat_statements_track = "top"
    public_access            = true
    version                  = var.database_version
  }
}

# Required by app
resource "upcloud_managed_database_logical_database" "postgres" {
  depends_on = [upcloud_managed_database_postgresql.database]
  service    = upcloud_managed_database_postgresql.database.id
  name       = "postgres"
}

locals {
  public_hostname = [for c in upcloud_managed_database_postgresql.database.components : c if c.route == "public" && c.component == "pg"][0].host
  public_port     = [for c in upcloud_managed_database_postgresql.database.components : c if c.route == "public" && c.component == "pg"][0].port
}

provider "postgresql" {
  scheme           = "postgres"
  host             = local.public_hostname
  port             = local.public_port
  username         = upcloud_managed_database_postgresql.database.service_username
  password         = upcloud_managed_database_postgresql.database.service_password
  superuser        = false
  sslmode          = "require"
  expected_version = var.database_version
}

resource "random_string" "app-pass" {
  depends_on = []
  length     = 32
  special    = false
}

resource "postgresql_role" "app" {
  depends_on         = [
    upcloud_managed_database_logical_database.postgres,
    random_string.app-pass,
  ]
  create_database    = true
  name               = var.database_username
  login              = true
  password           = random_string.app-pass.result
  encrypted_password = true
}

resource "vault_generic_secret" "database-credentials" {
  depends_on = [random_string.app-pass]
  path       = "secret/${var.vault_secret_name}/${var.configuration_name}"
  data_json  = <<EOT
{
  "username": "${var.database_username}",
  "password": "${random_string.app-pass.result}"
}
EOT
}

