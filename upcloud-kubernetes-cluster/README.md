# terraform-upcloud-kubernetes

> Terraform module for provisioning production-grade Kubernetes clusters on UpCloud with private networking, per-node storage, firewall hardening, and load balancing.

---

## Overview

This module automates the full infrastructure lifecycle for a Kubernetes cluster running on [UpCloud](https://upcloud.com). It provisions master and worker nodes with isolated private networking, configurable additional storage (CSI-compatible), granular firewall rules, and an optional load balancer — all parameterised for reuse across environments and zones.

Designed for teams who want reproducible, version-controlled Kubernetes infrastructure on UpCloud without manual portal configuration.

---

## Architecture

```
                        ┌─────────────────────────────────┐
                        │         UpCloud Zone             │
                        │                                  │
          Public IPs    │  ┌──────────┐  ┌──────────┐     │
        ───────────────►│  │  Master  │  │  Master  │     │
                        │  │  Node 1  │  │  Node N  │     │
                        │  └────┬─────┘  └────┬─────┘     │
                        │       │              │           │
                        │  ┌────▼──────────────▼─────┐    │
                        │  │     Private Network      │    │
                        │  │     (DHCP / IPv4)        │    │
                        │  └────┬──────────────┬──────┘    │
                        │       │              │           │
                        │  ┌────▼─────┐  ┌────▼─────┐     │
                        │  │  Worker  │  │  Worker  │     │
                        │  │  Node 1  │  │  Node N  │     │
                        │  └──────────┘  └──────────┘     │
                        │                                  │
                        │  ┌───────────────────────────┐  │
                        │  │  Load Balancer (optional) │  │
                        │  │  frontend → backend pool  │  │
                        │  └───────────────────────────┘  │
                        └─────────────────────────────────┘
```

Each node is provisioned with **three network interfaces**:
- `public` — internet-facing
- `private` — intra-cluster communication
- `utility` — UpCloud managed database access

---

## Features

- **Multi-node Kubernetes clusters** — separate master and worker node pools, fully configurable
- **Private network isolation** — dedicated IPv4 DHCP network for secure intra-cluster traffic
- **Per-node additional storage** — attach extra disks per node with configurable size and tier; CSI driver lifecycle ignored to prevent Terraform drift
- **Tri-homed networking** — public, private, and utility interfaces per server
- **Firewall hardening** — allowlist-based rules for Kubernetes API (port 6443), SSH (port 22), and UpCloud DNS; default-deny for all other inbound traffic
- **Optional load balancer** — UpCloud managed LB with health checks, frontend/backend separation, and up to 50,000 concurrent sessions (production-small plan)
- **Fully parameterised** — zone-agnostic, prefix support for multi-environment deployments, reusable across projects

---

## Requirements

| Tool | Version |
|------|---------|
| Terraform | >= 0.13 |
| UpCloud Terraform Provider | >= 2.5.0 |
| UpCloud account | — |

---

## Usage

```hcl
module "k8s_cluster" {
  source = "./path-to-module"

  prefix               = "prod"
  zone                 = "fi-hel1"
  template_name        = "Ubuntu Server 22.04 LTS (Noble Numbat)"
  username             = "ubuntu"
  private_network_cidr = "10.0.0.0/24"
  firewall_enabled     = true

  ssh_public_keys = [
    "ssh-rsa AAAA...your-key-here"
  ]

  machines = {
    master-1 = {
      node_type  = "master"
      plan       = "2xCPU-4GB"
      cpu        = null
      mem        = null
      disk_size  = 50
      additional_disks = {}
    }
    worker-1 = {
      node_type  = "worker"
      plan       = "4xCPU-8GB"
      cpu        = null
      mem        = null
      disk_size  = 80
      additional_disks = {
        data = {
          size = 100
          tier = "maxiops"
        }
      }
    }
  }

  master_allowed_remote_ips = [
    {
      start_address = "1.2.3.4"
      end_address   = "1.2.3.4"
    }
  ]

  k8s_allowed_remote_ips = [
    {
      start_address = "1.2.3.4"
      end_address   = "1.2.3.4"
    }
  ]

  loadbalancer_enabled = true
  loadbalancer_plan    = "production-small"

  loadbalancers = {
    api = {
      frontend_port   = 443
      backend_port    = 6443
      backend_servers = ["master-1"]
    }
  }
}
```

---

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `prefix` | Resource name prefix for multi-environment support | `string` | yes |
| `zone` | UpCloud zone (e.g. `fi-hel1`, `de-fra1`) | `string` | yes |
| `template_name` | Server OS template name | `string` | yes |
| `username` | SSH login username | `string` | yes |
| `private_network_cidr` | CIDR block for private cluster network | `string` | yes |
| `machines` | Map of machines with node type, plan, CPU, memory, disk, and additional disks | `map(object)` | yes |
| `ssh_public_keys` | List of SSH public keys for node access | `list(string)` | yes |
| `firewall_enabled` | Enable UpCloud firewall on nodes | `bool` | yes |
| `master_allowed_remote_ips` | IP ranges allowed to access Kubernetes API (port 6443) | `list(object)` | yes |
| `k8s_allowed_remote_ips` | IP ranges allowed SSH access to all nodes | `list(object)` | yes |
| `loadbalancer_enabled` | Deploy UpCloud managed load balancer | `bool` | yes |
| `loadbalancer_plan` | Load balancer plan (e.g. `production-small`) | `string` | yes |
| `loadbalancers` | Load balancer frontend/backend configuration | `map(object)` | yes |

---

## Outputs

| Name | Description |
|------|-------------|
| `master_ip` | Map of master hostnames to public and private IP addresses |
| `worker_ip` | Map of worker hostnames to public and private IP addresses |
| `loadbalancer_domain` | DNS name of the load balancer (null if disabled) |

---

## Security Design

- Kubernetes API server (port 6443) is restricted to explicitly allowlisted IP ranges; all other sources are denied
- SSH (port 22) is restricted to allowlisted IP ranges with default-deny
- UpCloud DNS resolver IPs are explicitly allowed
- All nodes sit behind a private network for intra-cluster communication
- Firewall rules are managed as code — no manual portal changes required

---

## Notes

- `storage_devices` lifecycle changes are ignored on all nodes to prevent Terraform from destroying CSI-provisioned volumes during plan/apply
- The utility network interface is required for accessing UpCloud managed databases from cluster workloads
- Load balancer health checks use TCP on `/healthz`; HTTP health checks with HTTPS backends are not supported by the UpCloud provider at this version

---

## License

MIT