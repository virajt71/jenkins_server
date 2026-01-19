output "vm_ids" {
  description = "Map of virtual machine IDs"
  value       = { for k, v in azurerm_linux_virtual_machine.this : k => v.id }
}

output "vm_names" {
  description = "Map of virtual machine names"
  value       = { for k, v in azurerm_linux_virtual_machine.this : k => v.name }
}

output "vm_private_ips" {
  description = "Map of virtual machine private IP addresses"
  value       = { for k, v in azurerm_linux_virtual_machine.this : k => v.private_ip_address }
}

output "generated_passwords" {
  description = "Map of generated admin passwords (sensitive)"
  value       = var.generate_admin_password ? { for k, v in random_password.this : k => v.result } : {}
  sensitive   = false
}


# output "ssh_private_keys" {
#   description = "Map of generated SSH private keys (sensitive)"
#   value       = var.generate_ssh_key ? { for k, v in azapi_resource_action.ssh_public_key_gen : k => v.output.privateKey } : {}
#   sensitive   = true
# }

# output "ssh_public_keys" {
#   description = "Map of generated SSH public keys"
#   value       = var.generate_ssh_key ? { for k, v in azapi_resource_action.ssh_public_key_gen : k => v.output.publicKey } : {}
# }
