# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  subscription_id = "dc454b64-1246-4b92-8f44-d6c2ba66e23c"
}

locals {
  location = "polandcentral"
}

variable "name" {
  type    = string
  default = "ca-devops-01"
}

variable "VM_name" {
  type    = string
  default = "devops-vm-01"
}

variable "admin_password" {
  description = "Admin password"
  type        = string
  sensitive   = true 
}

resource "azurerm_resource_group" "ca-devops-01" {
  name     = var.name
  location = local.location
}

resource "azurerm_virtual_network" "ca-devops-01" {
  name                = "${var.name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = local.location
  resource_group_name = azurerm_resource_group.ca-devops-01.name
}

resource "azurerm_subnet" "ca-devops-01" {
  name                 = "${var.name}-subnet"
  resource_group_name  = azurerm_resource_group.ca-devops-01.name
  virtual_network_name = azurerm_virtual_network.ca-devops-01.name
  address_prefixes     = ["10.0.10.0/24"]
}

resource "azurerm_network_security_group" "ca-devops-01" {
  name                = "${var.name}-nsg"
  location            = azurerm_resource_group.ca-devops-01.location
  resource_group_name = azurerm_resource_group.ca-devops-01.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "ca-devops-01" {
  subnet_id                 = azurerm_subnet.ca-devops-01.id
  network_security_group_id = azurerm_network_security_group.ca-devops-01.id
}

resource "azurerm_public_ip" "ca-devops-01" {
  name                = "${var.name}-pip"
  location            = azurerm_resource_group.ca-devops-01.location
  resource_group_name = azurerm_resource_group.ca-devops-01.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "ca-devops-01" {
  name                = "${var.name}-nic"
  location            = azurerm_resource_group.ca-devops-01.location
  resource_group_name = azurerm_resource_group.ca-devops-01.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ca-devops-01.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ca-devops-01.id
  }
}

resource "azurerm_linux_virtual_machine" "ca-devops-01" {
  name                = var.VM_name
  resource_group_name = azurerm_resource_group.ca-devops-01.name
  location            = azurerm_resource_group.ca-devops-01.location
  size                = "Standard_B2ats_v2"
  admin_username      = "azureuser"
  disable_password_authentication = false
  admin_password = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.ca-devops-01.id,
  ]

os_disk {
  caching              = "ReadWrite"
  storage_account_type = "Standard_LRS"
}

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

output "public_ip" {
  value = azurerm_public_ip.ca-devops-01.ip_address
}