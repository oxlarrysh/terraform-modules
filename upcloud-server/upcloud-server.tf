resource "upcloud_server" "master" {
  for_each = {
  for name, machine in var.machines :
  name => machine
  if machine.node_type == "master"
  }

  hostname = "${each.key}.${var.hostname}"
  zone = each.value.zone

  # Number of CPUs and memory in GB
  plan = each.value.plan

  # ALTERNATIVE: You either have to define plan OR cpu & mem, never both
  cpu = each.value.cpu
  mem = each.value.mem

  template {
    storage = coalesce(each.value.disk_uuid, var.template_name)
    size = each.value.disk_size

    backup_rule {
      interval = "daily"
      time = "0100"
      retention = 8
    }
  }

  # Network interfaces
  network_interface {
    type = "public"
  }

  network_interface {
    type = "utility"
  }

  # Include at least one public SSH key
  login {
    user = var.username
    keys = var.ssh_public_keys
    create_password = false
  }

  tags = ["terraform"]
}

resource "upcloud_server" "worker" {
  for_each = {
  for name, machine in var.machines :
  name => machine
  if machine.node_type == "worker"
  }

  hostname = "${each.key}.${var.hostname}"
  zone = each.value.zone

  # Number of CPUs and memory in GB
  plan = each.value.plan

  # ALTERNATIVE: You either have to define plan OR cpu & mem, never both
  cpu = each.value.cpu
  mem = each.value.mem

  template {
    storage = var.template_name
    size = each.value.disk_size
  }

  # Network interfaces
  network_interface {
    type = "public"
  }

  network_interface {
    type = "utility"
  }

  # Include at least one public SSH key
  login {
    user = var.username
    keys = var.ssh_public_keys
    create_password = false
  }

  tags = ["terraform"]
}
