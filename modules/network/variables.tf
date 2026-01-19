variable "name" {
  description = "Prefix for resource names"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.name))
    error_message = "Resource group name can only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "location" {
  description = "Azure region"
  type        = string

  validation {
    condition = contains([
      "northeurope", "westeurope", "uksouth", "ukwest"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Map of subnets to create"
  type = map(object({
    address_prefixes = list(string)
    delegations = optional(map(object({
      name    = string
      actions = list(string)
    })), {})
  }))
  default = {
    default = {
      address_prefixes = ["10.0.1.0/24"]
    }
  }
}

variable "public_ips" {
  description = "Map of public IPs to create"
  type = map(object({
    allocation_method = string
    sku               = string
  }))
  default = {}
}

variable "network_security_groups" {
  description = "Map of network security groups to create"
  type = map(object({
    security_rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  }))
  default = {}
}

variable "network_interfaces" {
  description = "Map of network interfaces to create"
  type = map(object({
    subnet_key                    = string
    private_ip_address_allocation = string
    private_ip_address            = optional(string)
    public_ip_key                 = optional(string)
  }))
  default = {}
}

variable "nic_nsg_associations" {
  description = "Map of NIC to NSG associations"
  type = map(object({
    nic_key = string
    nsg_key = string
  }))
  default = {}
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
