# terraform-modules

A collection of reusable, production-grade Terraform modules for cloud infrastructure provisioning — primarily targeting [UpCloud](https://upcloud.com) with a focus on Kubernetes clusters, managed databases, object storage, and backup/DR automation.

These modules were developed and used in real production environments. Each module is independently versioned, parameterised for multi-environment reuse, and follows Terraform best practices for state management and lifecycle safety.

---

## Modules

### Kubernetes & Compute

| Module | Description |
|--------|-------------|
| [`upcloud-kubernetes-cluster`](./upcloud-kubernetes-cluster) | Full Kubernetes cluster on UpCloud — master/worker nodes, private networking, per-node storage, firewall hardening, and load balancing |
| [`upcloud-server`](./upcloud-server) | General-purpose UpCloud server provisioning with network and storage configuration |

### Database & Storage

| Module | Description |
|--------|-------------|
| [`upcloud-managed-postgresql`](./upcloud-managed-postgresql) | UpCloud managed postgresql for Apps |
| [`upcloud-managed-object-storage`](./upcloud-managed-object-storage) | UpCloud managed object storage for Apps |
| [`upcloud-object-storage`](./upcloud-object-storage) | UpCloud object storage (self-managed) for Apps |

### Backup & Disaster Recovery

| Module | Description |
|--------|-------------|
| [`k8s-velero`](./k8s-velero) | Velero installation and configuration for Kubernetes backup and disaster recovery |
| [`upcloud-backup`](./upcloud-backup) | Automated backup module for UpCloud deployments |

---

## Design Principles

- **Reusable by default** — every module is parameterised and prefixed for safe multi-environment deployment (dev, staging, prod)
- **Lifecycle-safe** — storage devices managed by CSI drivers are excluded from Terraform lifecycle to prevent accidental volume destruction
- **Security-first** — firewall rules, network isolation, and access controls are managed as code; no manual portal configuration required
- **Minimal dependencies** — each module is self-contained with its own `versions.tf` and can be consumed independently

---

## Repository Structure

```
terraform-modules/
├── upcloud-kubernetes-cluster/   # Kubernetes cluster on UpCloud
│   ├── main.tf
│   ├── variables.tf
│   ├── output.tf
│   ├── versions.tf
│   └── README.md
├── upcloud-server/                 # Bare server provisioning
├── upcloud-managed-postgresql/     # Upcloud managed postgresql for Apps
├── upcloud-managed-object-storage/ # Upcloud managed object storage
├── k8s-velero/                     # Kubernetes backup/DR
└── backup/                         # Backup automation
```

---

## Requirements

| Tool | Minimum Version |
|------|----------------|
| Terraform | >= 0.13 |
| UpCloud Terraform Provider | >= 2.5.0 |

---

## Usage

Each module can be consumed independently. Reference a module directly from this repository:

```hcl
module "k8s_cluster" {
  source = "github.com/oxlarrysh/terraform-modules//upcloud-kubernetes-cluster"

  prefix               = "prod"
  zone                 = "fi-hel1"
  # ... see module README for full variable reference
}
```

Or clone the repo and reference locally:

```hcl
module "k8s_cluster" {
  source = "./upcloud-kubernetes-cluster"
  # ...
}
```

---

## Author

**Olanrewaju Oladunjoye**
Senior Platform & DevOps Engineer

---

## License

MIT