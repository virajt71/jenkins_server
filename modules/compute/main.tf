# Random password generation
resource "random_password" "this" {
  for_each = var.generate_admin_password ? var.virtual_machines : {}

  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

# SSH Key generation
resource "azapi_resource" "ssh_public_key" {
  for_each = var.generate_ssh_key ? var.virtual_machines : {}

  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = "${var.name}-${each.key}-ssh-key"
  location  = var.location
  parent_id = var.resource_group_id

  tags = var.tags
}

resource "azapi_resource_action" "ssh_public_key_gen" {
  for_each = var.generate_ssh_key ? var.virtual_machines : {}

  type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id = azapi_resource.ssh_public_key[each.key].id
  action      = "generateKeyPair"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]
}

# resource "local_file" "ssh_private_keys" {
#   for_each = module.compute.ssh_private_keys

#   filename        = pathexpand("~/.ssh/azure_${each.key}_rsa.pub")
#   content         = each.value
#   file_permission = "0600"
# }

# # Save SSH public keys to local files
# resource "local_file" "ssh_public_keys" {
#   for_each = module.compute.ssh_public_keys

#   filename        = pathexpand("~/.ssh/azure_${each.key}_public_rsa.pub")
#   content         = each.value
#   file_permission = "0644"
# }

# Linux Virtual Machines
resource "azurerm_linux_virtual_machine" "this" {
  for_each = var.virtual_machines

  name                            = "${var.name}-${each.key}"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = each.value.size
  network_interface_ids           = [var.network_interface_ids[each.value.nic_key]]
  admin_username                  = each.value.admin_username
  disable_password_authentication = each.value.disable_password_authentication
  custom_data                     = each.value.custom_data

  # Use generated password if password auth is enabled and no password provided
  admin_password = !each.value.disable_password_authentication ? (
    each.value.admin_password != null ? each.value.admin_password :
    var.generate_admin_password ? random_password.this[each.key].result : null
  ) : null

  os_disk {
    name                 = "${var.name}-${each.key}-osdisk"
    caching              = each.value.os_disk.caching
    storage_account_type = each.value.os_disk.storage_account_type
    disk_size_gb         = lookup(each.value.os_disk, "disk_size_gb", null)
  }

  source_image_reference {
    publisher = each.value.source_image.publisher
    offer     = each.value.source_image.offer
    sku       = each.value.source_image.sku
    version   = each.value.source_image.version
  }

  # SSH key configuration
  dynamic "admin_ssh_key" {
    for_each = each.value.disable_password_authentication ? [1] : []
    content {
      username = each.value.admin_username
      public_key = each.value.ssh_public_key != null ? each.value.ssh_public_key : (
        var.generate_ssh_key ? azapi_resource_action.ssh_public_key_gen[each.key].output.publicKey : ""
      )
    }
  }

  # Boot diagnostics
  dynamic "boot_diagnostics" {
    for_each = var.enable_boot_diagnostics ? [1] : []
    content {
      storage_account_uri = var.boot_diagnostics_storage_uri
    }
  }

  tags = var.tags

  depends_on = [azapi_resource_action.ssh_public_key_gen]
}
