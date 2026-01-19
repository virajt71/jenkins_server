output "rg_name" {
  value = azurerm_resource_group.this.name
}

output "sa_name" {
 value = azurerm_storage_account.this.name
}

output "container_name" {
  value = azurerm_storage_container.this.name
}
