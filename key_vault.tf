data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault" "spoke" {
  name                        = "spoke-key-vault"
  location                    = azurerm_resource_group.spoke.location
  resource_group_name         = azurerm_resource_group.spoke.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", 
      "Create",
      "Update",
    #   "Delete",
    ]

    secret_permissions = [
      "Get",
    #   "Delete",
      "Set",
    ]

    storage_permissions = [
      "Get",
      "Update",
    #   "Delete",
      "Set",
    ]
  }
}
