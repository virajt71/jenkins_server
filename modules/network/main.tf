resource "azurerm_virtual_network" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes

  dynamic "delegation" {
    for_each = lookup(each.value, "delegations", {})
    content {
      name = delegation.key
      service_delegation {
        name    = delegation.value.name
        actions = delegation.value.actions
      }
    }
  }
}

resource "azurerm_public_ip" "this" {
  for_each = var.public_ips

  name                = "${var.name}-${each.key}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku
  tags                = var.tags
}

resource "azurerm_network_security_group" "this" {
  for_each = var.network_security_groups

  name                = "${var.name}-${each.key}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "security_rule" {
    for_each = each.value.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_network_interface" "this" {
  for_each = var.network_interfaces

  name                = "${var.name}-${each.key}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.this[each.value.subnet_key].id
    private_ip_address_allocation = each.value.private_ip_address_allocation
    private_ip_address            = lookup(each.value, "private_ip_address", null)
    public_ip_address_id          = lookup(each.value, "public_ip_key", null) != null ? azurerm_public_ip.this[each.value.public_ip_key].id : null
  }
}

resource "azurerm_network_interface_security_group_association" "this" {
  for_each = var.nic_nsg_associations

  network_interface_id      = azurerm_network_interface.this[each.value.nic_key].id
  network_security_group_id = azurerm_network_security_group.this[each.value.nsg_key].id
}
