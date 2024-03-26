resource "azurerm_resource_group" "spoke" {
  name     = "spoke-resources"
  location = var.default_location
}

resource "azurerm_network_security_group" "spoke" {
  name                = "spoke-security-group"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
}

resource "azurerm_virtual_network" "spoke" {
  name                = "spoke-network"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  address_space       = ["10.1.0.0/16"]
  dns_servers         = ["10.1.0.4", "10.1.0.5"]

  subnet {
    name           = "spoke_subnet1"
    address_prefix = "10.1.1.0/24"
    security_group = azurerm_network_security_group.spoke.id
  }

  subnet {
    name           = "spoke_subnet2"
    address_prefix = "10.1.2.0/24"
    security_group = azurerm_network_security_group.spoke.id
  }

  tags = {
    environment = "Production"
  }
}