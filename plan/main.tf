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
    macaddr  = "5a:fe:6c:96:40:6${count.index}"
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
    macaddr  = "5a:fe:6c:96:40:7${count.index}"
    bridge   = "vmbr0"
    firewall = true
  }

  lifecycle {
     ignore_changes = [
       network
     ]
  }
}
