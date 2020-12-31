terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.6.6"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://${var.pve_ip}:8006/api2/json"
  pm_user         = var.pve_user
  pm_password     = var.pve_password
  pm_tls_insecure = "true"
}

resource "proxmox_vm_qemu" "k3s-servers" {
  count       = var.server_count
  name        = var.server_names[count.index]
  target_node = var.pve_node
  desc        = "k3s server #${count.index + 1}"
  vmid        = 0
  cpu         = var.cpu
  cores       = var.server_cores
  memory      = var.server_memory
  scsihw      = "virtio-scsi-pci"
  boot        = "order=scsi0;ide2"
  onboot      = false
  agent       = 1
  iso         = var.k3os_iso

  disk {
    size    = "${var.server_disk_size}G"
    type    = "scsi"
    storage = var.disk_storage
    backup  = true
  }

  network {
    model    = "virtio"
    macaddr  = "${var.server_mac_prefix}${count.index}"
    bridge   = "vmbr0"
    firewall = true
  }

  lifecycle {
     ignore_changes = [
       network
     ]
  }
}

resource "proxmox_vm_qemu" "k3s-agents" {
  count       = var.agent_count
  name        = var.agent_names[count.index]
  target_node = var.pve_node
  desc        = "k3s agent #${count.index + 1}"
  vmid        = 0
  cpu         = var.cpu
  cores       = var.agent_cores
  memory      = var.agent_memory
  scsihw      = "virtio-scsi-pci"
  boot        = "order=scsi0;ide2"
  onboot      = false
  agent       = 1
  iso         = var.k3os_iso

  disk {
    size    = "${var.agent_disk_size}G"
    type    = "scsi"
    storage = var.disk_storage
    backup  = true
  }

  network {
    model    = "virtio"
    macaddr  = "${var.agent_mac_prefix}${count.index}"
    bridge   = "vmbr0"
    firewall = true
  }

  lifecycle {
     ignore_changes = [
       network
     ]
  }
}
