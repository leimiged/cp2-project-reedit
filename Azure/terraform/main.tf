terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.10.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "cp2" {
  name     = "CP-2"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnet-cp2" {
  name                = "vnet-cp-2"
  location            = azurerm_resource_group.cp2.location
  resource_group_name = azurerm_resource_group.cp2.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "sub-cp2" {
  name                 = "subnet-cp-2"
  resource_group_name  = azurerm_resource_group.cp2.name
  virtual_network_name = azurerm_virtual_network.vnet-cp2.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "nic-cp2" {
  name                = "example-nic"
  location            = azurerm_resource_group.cp2.location
  resource_group_name = azurerm_resource_group.cp2.name

  ip_configuration {
    name                          = "pip-cp2"
    subnet_id                     = azurerm_subnet.sub-cp2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "nsg-cp2" {
  name                = "nsg-cp2"
  location            = azurerm_resource_group.cp2.location
  resource_group_name = azurerm_resource_group.cp2.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "80"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}