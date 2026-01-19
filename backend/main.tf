resource "random_string" "this" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_resource_group" "this" {
  name     = "${local.name}-rg"
  location = local.location
}

resource "azurerm_storage_account" "this" {
  name                            = "${local.name}${random_string.this.result}"
  resource_group_name             = azurerm_resource_group.this.name
  location                        = azurerm_resource_group.this.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  tags                            = local.common_tags
}

resource "azurerm_storage_container" "this" {
  name                  = local.name
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}
