terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  tenant_id       = "4df449e1-ca04-46fa-ba74-52c910e5a455"
  subscription_id = var.azure_subscription_id
}

resource "azurerm_resource_group" "cranky" {
  name     = "cranky-prod"
  location = "Southeast Asia"
}

resource "azurerm_virtual_network" "cranky" {
  name                = "cranky-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.cranky.location
  resource_group_name = azurerm_resource_group.cranky.name
}

resource "azurerm_subnet" "cranky" {
  name                 = "cranky-subnet"
  resource_group_name  = azurerm_resource_group.cranky.name
  virtual_network_name = azurerm_virtual_network.cranky.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "cranky" {
  name                = "cranky-nsg"
  location            = azurerm_resource_group.cranky.location
  resource_group_name = azurerm_resource_group.cranky.name

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

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAppPort8001"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8001"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "cranky" {
  name                = "cranky-pip"
  location            = azurerm_resource_group.cranky.location
  resource_group_name = azurerm_resource_group.cranky.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "cranky" {
  name                = "cranky-nic"
  location            = azurerm_resource_group.cranky.location
  resource_group_name = azurerm_resource_group.cranky.name

  ip_configuration {
    name                          = "testConfiguration"
    subnet_id                     = azurerm_subnet.cranky.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.cranky.id
  }
}

resource "azurerm_network_interface_security_group_association" "cranky" {
  network_interface_id      = azurerm_network_interface.cranky.id
  network_security_group_id = azurerm_network_security_group.cranky.id
}

resource "azurerm_linux_virtual_machine" "cranky" {
  name                = "cranky-prod-vm"
  location            = azurerm_resource_group.cranky.location
  resource_group_name = azurerm_resource_group.cranky.name
  size                = "Standard_B2s_v2"

  network_interface_ids = [
    azurerm_network_interface.cranky.id,
  ]

  admin_username = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(pathexpand("~/.ssh/id_rsa.pub"))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(file("${path.module}/init.sh"))
}

output "public_ip" {
  value       = azurerm_public_ip.cranky.ip_address
  description = "Public IP address of the VM"
}

output "vm_name" {
  value       = azurerm_linux_virtual_machine.cranky.name
  description = "VM name"
}
