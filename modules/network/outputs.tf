output "vnet_id" {
  description = "Virtual network ID"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Virtual network name"
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Map of subnet IDs"
  value       = { for k, v in azurerm_subnet.this : k => v.id }
}

output "public_ip_ids" {
  description = "Map of public IP IDs"
  value       = { for k, v in azurerm_public_ip.this : k => v.id }
}

output "public_ip_addresses" {
  description = "Map of public IP addresses"
  value       = { for k, v in azurerm_public_ip.this : k => v.ip_address }
}

output "nic_ids" {
  description = "Map of network interface IDs"
  value       = { for k, v in azurerm_network_interface.this : k => v.id }
}

output "nsg_ids" {
  description = "Map of network security group IDs"
  value       = { for k, v in azurerm_network_security_group.this : k => v.id }
}
