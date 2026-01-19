variable "name" {
  description = "Prefix for resource names"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "resource_group_id" {
  description = "Resource group ID (required for SSH key generation)"
  type        = string
}

variable "network_interface_ids" {
  description = "Map of network interface IDs"
  type        = map(string)
}

variable "virtual_machines" {
  description = "Map of virtual machines to create"
  type = map(object({
    size                            = string
    nic_key                         = string
    admin_username                  = string
    admin_password                  = optional(string)
    disable_password_authentication = optional(bool, true)
    ssh_public_key                  = optional(string)
    custom_data                     = optional(string)

    os_disk = object({
      caching              = string
      storage_account_type = string
      disk_size_gb         = optional(number)
    })

    source_image = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })

    tags = optional(map(string), {})
  }))
}

variable "generate_admin_password" {
  description = "Generate random admin password for VMs with password authentication"
  type        = bool
  default     = true
}

variable "generate_ssh_key" {
  description = "Generate SSH key pairs for VMs"
  type        = bool
  default     = true
}

variable "enable_boot_diagnostics" {
  description = "Enable boot diagnostics for VMs"
  type        = bool
  default     = false
}

variable "boot_diagnostics_storage_uri" {
  description = "Storage URI for boot diagnostics"
  type        = string
  default     = null
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
