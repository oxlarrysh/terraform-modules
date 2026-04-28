# The username of the server's operating system
variable "username" {}

variable "ssh_public_keys" {
  type = list(string)
}

variable "hostname" {
  default = "example.com"
}


variable "template_name" {}

variable "kube_labels" {
  type = list(string)
  default = []
}

variable "machines" {
  description = "Cluster machines"
  type = map(object({
    node_type = string
    plan = string
    cpu = string
    mem = string
    disk_size = number
    zone = string
    floating_ip = optional(bool)  # Only available for workers
    disk_uuid = optional(string)  # Only needed for emergency recovery
  }))
}
