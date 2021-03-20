variable "api_url" {
  description = "Rancher API URL"
  default     = "https://rancher.local"
}

variable "admin_password" {
  description = "Rancher admin password"
  sensitive   = true
}

variable "telemetry" {
  description = "Allow Rancher to collect anonymous data"
  type        = bool
  default     = false
}

variable "new_admin_user" {
  description = "New username replacing the default admin"
  default     = "newadmin"
}

variable "new_admin_password" {
  description = "New admin password"
  sensitive   = true
}
