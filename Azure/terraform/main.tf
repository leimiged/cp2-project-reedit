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
  location = "francecentral"
}

resource "azurerm_virtual_network" "vnet-cp2" {
  name                = "vnetcp2"
  location            = azurerm_resource_group.cp2.location
  resource_group_name = azurerm_resource_group.cp2.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "sub-cp2" {
  name                 = "subnetcp2"
  resource_group_name  = azurerm_resource_group.cp2.name
  virtual_network_name = azurerm_virtual_network.vnet-cp2.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "nic-cp2" {
  for_each            = toset(var.names)
  name                = "${each.key}-nic"
  location            = azurerm_resource_group.cp2.location
  resource_group_name = azurerm_resource_group.cp2.name

  ip_configuration {
    name                          = "pipcp2"
    subnet_id                     = azurerm_subnet.sub-cp2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "nsg-cp2" {
  name                = "nsgcp2"
  location            = azurerm_resource_group.cp2.location
  resource_group_name = azurerm_resource_group.cp2.name

  security_rule {
    name                       = "cp2_rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "80"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "cp2_ssh_rule"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_linux_virtual_machine" "cp2" {
  for_each              = toset(var.names)
  name                  = each.value
  resource_group_name   = azurerm_resource_group.cp2.name
  location              = azurerm_resource_group.cp2.location
  size                  = "Standard_B2s"
  admin_username        = "ansible"
  network_interface_ids = [azurerm_network_interface.nic-cp2[each.key].id]

  admin_ssh_key {
    username   = "ansible"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "${each.key}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = "32"
  }

  source_image_reference {
    publisher = var.linux_vm_image_publisher
    offer     = var.linux_vm_image_offer
    sku       = var.centos_8_sku
    version   = "latest"
  }
}