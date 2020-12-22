variable "pve_ip" {
  description = "Proxmox DNS or IP"
  default     = "proxmox"
}

variable "pve_user" {
  description = "Proxmox user"
  default     = "root@pam"
}

variable "pve_password" {
  description = "Proxmox user password"
  sensitive   = true
}

variable "pve_node" {
  description = "Proxmox target node"
  default     = "proxmox"
}

variable "cpu" {
  description = "Emulated CPU type"
  default     = "host"
}

variable "k3os_iso" {
  description = "k3OS iso to use for installation"
  default     = "local:iso/remastered-k3os-amd64-v0.11.1.iso"
}

variable "disk_storage" {
  description = "Disk storage for k3s VMs"
  default     = "local-lvm"
}

variable "server_count" {
  description = "Number of k3s servers"
  type        = number
  default     = 1
}

variable "server_names" {
  description = "k3s server names"
  type        = list(string)
  default     = ["server1","server2","server3"]
}

variable "server_cores" {
  description = "Number of cores for k3s servers"
  type        = number
  default     = 1
}

variable "server_memory" {
  description = "Memory for k3s servers (in MB)"
  type        = number
  default     = 1024
}

variable "server_disk_size" {
  description = "Disk size for k3s servers (in GB)"
  type        = number
  default     = 32
}

variable "agent_count" {
  description = "Number of k3s agents"
  type        = number
  default     = 1
}

variable "agent_names" {
  description = "k3s agent names"
  type        = list(string)
  default     = ["agent1","agent2","agent3"]
}

variable "agent_cores" {
  description = "Number of cores for k3s agents"
  type        = number
  default     = 1
}

variable "agent_memory" {
  description = "Memory for k3s agents (in MB)"
  type        = number
  default     = 1024
}

variable "agent_disk_size" {
  description = "Disk size for k3s agents (in GB)"
  type        = number
  default     = 32
}
