output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group.name
}

output "resource_group_id" {
  value = module.resource_group.id
}

output "vm_public_ip_addresses" {
  description = "Public IP addresses of VMs"
  value       = module.network.public_ip_addresses
}

output "vm_private_ip_addresses" {
  description = "Private IP addresses of VMs"
  value       = module.compute.vm_private_ips
}

output "ssh_connection_commands" {
  description = "SSH connection commands for VMs"
  value = {
    for k, v in module.network.public_ip_addresses :
    k => "ssh azureuser@${v}"
  }
}

# Sensitive outputs (use terraform output -json to view)
# output "generated_ssh_private_keys" {
#   description = "Generated SSH private keys"
#   value       = module.compute.ssh_private_keys
#   sensitive   = true
# }

output "generated_admin_passwords" {
  description = "Generated admin passwords for VMs"
  value       = module.compute.generated_passwords
  sensitive   = true
}

# output "ssh_public_keys" {
#   description = "Generated SSH public keys"
#   value       = module.compute.ssh_public_keys
# }

# output "vault_pass" {
#   value = yamldecode(ansible_vault.jenkins_secrets.vault_password_file)
#   sensitive = false
# }

