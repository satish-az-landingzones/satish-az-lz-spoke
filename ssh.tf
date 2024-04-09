
resource "azapi_resource" "ssh_public_key" {
  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = "sshkey-spoke-dev-eastus-001"
  location  = azurerm_resource_group.spoke.location
  parent_id = azurerm_resource_group.spoke.id
}

resource "azapi_resource_action" "ssh_public_key_gen" {
  type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id = azapi_resource.ssh_public_key.id
  action      = "generateKeyPair"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]
}

resource "azurerm_key_vault_secret" "private_key" {
  name         = "private-key"
  value        = azapi_resource_action.ssh_public_key_gen.output["privateKey"]
  key_vault_id = azurerm_key_vault.spoke_key_vault.id
}

output "key_data" {
  value = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
}