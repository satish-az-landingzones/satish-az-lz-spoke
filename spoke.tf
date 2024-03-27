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

data "azurerm_subnet" "spoke_subnet1" {
  name                 = "spoke_subnet1"
  virtual_network_name = azurerm_virtual_network.spoke.name
  resource_group_name  = azurerm_resource_group.spoke.name
}

resource "azurerm_network_interface" "spoke" {
  name                = "spoke-vm-nic"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.spoke_subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "spoke" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.spoke.name
  location            = azurerm_resource_group.spoke.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.spoke.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key =jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}