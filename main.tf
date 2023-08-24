# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "scus-rg-01" {
  name     = "scus-rg-1"
  location = "South Central US"

  tags = {
    environment = "dev"
    project     = "tf-demo"
    owner       = "CSA_Advisor"
  }
}

resource "azurerm_virtual_network" "scus-vnet-01" {
  name                = "scus-vnet-01"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.scus-rg-01.location
  resource_group_name = azurerm_resource_group.scus-rg-01.name

  tags = {
    environment = "dev"
    project     = "tf-demo"
    owner       = "CSA_Advisor"
  }
}

resource "azurerm_subnet" "scus-snet-01" {
  name                 = "scus-snet-01"
  resource_group_name  = azurerm_resource_group.scus-rg-01.name
  virtual_network_name = azurerm_virtual_network.scus-vnet-01.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "scus-nic-01" {
  name                = "scus-nic-01"
  location            = azurerm_resource_group.scus-rg-01.location
  resource_group_name = azurerm_resource_group.scus-rg-01.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.scus-snet-01.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    environment = "dev"
    project     = "tf-demo"
    owner       = "CSA_Advisor"
  }
}

resource "azurerm_linux_virtual_machine" "scus-vm-lnx-01" {
  name                = "scus-vm-lnx-01"
  resource_group_name = azurerm_resource_group.scus-rg-01.name
  location            = azurerm_resource_group.scus-rg-01.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.scus-nic-01.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  tags = {
    environment = "dev"
    project     = "tf-demo"
    owner       = "CSA_Advisor"
  }

}