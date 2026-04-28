# upcloud-managed-postgresql
 
> Terraform module for provisioning a production-grade managed PostgreSQL database on UpCloud, with automated role creation, SSL-enforced access, and credential lifecycle management via HashiCorp Vault.
 
---
 
## Overview
 
This module provisions an UpCloud Managed PostgreSQL database with secure defaults — query monitoring enabled, public access over SSL required, and configurable IP filtering. It automates the full database user lifecycle: creating a logical database, generating a cryptographically random password, provisioning a dedicated PostgreSQL role, and storing credentials securely in HashiCorp Vault.
 
Designed for teams who want fully automated, auditable database provisioning without manual credential management or portal configuration.
 
---
 
## Features
 
- **Managed PostgreSQL on UpCloud** — configurable plan, zone, and version
- **IP filtering** — restrict access to specific IP ranges as code
- **Query monitoring** — `pg_stat_monitor` and `pg_stat_statements` enabled by default for performance visibility
- **Logical database provisioning** — creates a named logical database within the managed instance
- **Automated role management** — provisions a dedicated PostgreSQL role with `CREATE DATABASE` privileges
- **Random credential generation** — 32-character alphanumeric password generated at apply time, never hardcoded
- **SSL-enforced connections** — all provider connections use `sslmode = require`
- **HashiCorp Vault integration** — credentials written to Vault at a configurable path, enabling secret rotation and auditable access
- **Zero manual steps** — end-to-end database setup from Terraform apply
---
 
## Architecture
 
```
terraform apply
      │
      ▼
┌─────────────────────────────────────────┐
│         UpCloud Managed PostgreSQL       │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  Logical Database               │    │
│  │  (provisioned via pg provider)  │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  PostgreSQL Role                │    │
│  │  + random 32-char password      │    │
│  └─────────────────────────────────┘    │
└──────────────┬──────────────────────────┘
               │ SSL (sslmode=require)
               ▼
┌─────────────────────────────────────────┐
│         HashiCorp Vault                 │
│  secret/<path>/<name>                   │
│  { username, password }                 │
└─────────────────────────────────────────┘
```
 
---
 
## Requirements
 
| Tool | Version |
|------|---------|
| Terraform | >= 0.13 |
| UpCloud Provider | >= 2.5.0 |
| PostgreSQL Provider | >= 1.14 |
| HashiCorp Vault Provider | >= 3.0 |
| Random Provider | >= 3.0 |
 
---
 
## Usage
 
```hcl
module "postgresql" {
  source = "github.com/dunjoye4real/terraform-modules//upcloud-managed-postgresql"
 
  configuration_name = "production"
  plan               = "business-4"
  zone               = "fi-hel1"
  database_version   = "14"
  database_username  = "appuser"
  vault_secret_name  = "db-credentials"
 
  allowed_ip_ranges = [
    "10.0.0.0/24",
    "1.2.3.4/32"
  ]
}
```
 
---
 
## Inputs
 
| Name | Description | Type | Required |
|------|-------------|------|----------|
| `configuration_name` | Unique name for this database instance — used in resource naming and Vault path | `string` | yes |
| `plan` | UpCloud managed database plan (e.g. `business-4`, `startup-4`) | `string` | yes |
| `zone` | UpCloud zone (e.g. `fi-hel1`, `de-fra1`) | `string` | yes |
| `database_version` | PostgreSQL major version (e.g. `14`, `15`) | `string` | yes |
| `database_username` | PostgreSQL role name to create | `string` | yes |
| `vault_secret_name` | Vault secret key name under which credentials are stored | `string` | yes |
| `allowed_ip_ranges` | List of CIDR ranges permitted to connect to the database | `list(string)` | yes |
 
---
 
## Outputs
 
| Name | Description |
|------|-------------|
| `public_hostname` | Public hostname of the managed PostgreSQL instance |
| `public_port` | Public port of the managed PostgreSQL instance |
 
---
 
## Security Design
 
- **SSL required** — all connections enforced with `sslmode = require`; no plaintext connections permitted
- **Random credentials** — passwords are generated at apply time using the `random_string` resource; never stored in code or state in plaintext
- **Vault-backed secrets** — credentials are written to HashiCorp Vault immediately after generation, enabling secret rotation, audit logging, and dynamic access control
- **IP filtering** — database access is restricted to explicitly defined CIDR ranges; no open public access
- **Least-privilege role** — dedicated PostgreSQL role scoped to the provisioned database only
---
 
## Notes
 
- The `postgresql` provider connects to the database using the UpCloud service credentials during provisioning — these are temporary and used only at apply time
- The `vault_generic_secret` resource stores credentials at `secret/<configuration_name>/<vault_secret_name>` — ensure your Vault path policy permits writes to this path
- `pg_stat_monitor_enable` and `pg_stat_statements_track = "top"` are enabled by default to support query performance monitoring; disable in `properties` if not required
---
 
## License
 
MIT
 