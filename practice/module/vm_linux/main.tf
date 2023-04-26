locals {
  vm_name     = format("vm%s%s000", var.asset_name, var.environment)
  vnet_name   = format("vnet%s%s000", var.asset_name, var.environment)
  subnet_name = format("subnet%s%s000", var.asset_name, var.environment)
  pip_name    = format("pip%s%s000", var.asset_name, var.environment)
  nsg_name    = format("nsg%s%s000", var.asset_name, var.environment)
  nic_name    = format("nic%s%s000", var.asset_name, var.environment)
  sa_name     = format("sa%s%s000", var.asset_name, var.environment)
  username    = "azureuser"
}

# Create virtual network
resource "azurerm_virtual_network" "my_terraform_network" {
  count = var.instance_count

  name                = "${local.vnet_name}${count.index + 1}"
  address_space       = ["10.0.0.0/16"]
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  tags                = { environment = var.environment }
}

# Create subnet
resource "azurerm_subnet" "my_terraform_subnet" {
  count = var.instance_count

  name                 = "${local.subnet_name}${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.my_terraform_network[count.index].name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "my_terraform_public_ip" {
  count = var.instance_count

  name                = "${local.pip_name}${count.index + 1}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  tags                = { environment = var.environment }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "my_terraform_nsg" {
  count = var.instance_count

  name                = "${local.nsg_name}${count.index + 1}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = { environment = var.environment }
}

# Create network interface
resource "azurerm_network_interface" "my_terraform_nic" {
  count = var.instance_count

  name                = "${local.nic_name}${count.index + 1}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${local.nic_name}${count.index}_configuration"
    subnet_id                     = azurerm_subnet.my_terraform_subnet[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_terraform_public_ip[count.index].id
  }

  tags = { environment = var.environment }
}

# # Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "my_terraform_sga" {
  count = var.instance_count

  network_interface_id      = azurerm_network_interface.my_terraform_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg[count.index].id
}

# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    resource_group = var.resource_group_name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "my_storage_account" {
  count = var.instance_count

  name                     = "${local.sa_name}${count.index + 1}${random_id.random_id.hex}"
  location                 = var.resource_group_location
  resource_group_name      = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = { environment = var.environment }
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  count = var.instance_count

  name                  = "${local.vm_name}${count.index + 1}"
  location              = var.resource_group_location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.my_terraform_nic[count.index].id]
  size                  = "Standard_B1s"

  os_disk {
    name                 = "OsDisk${local.vm_name}${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  computer_name                   = "myvm_${count.index + 1}"
  admin_username                  = local.username
  disable_password_authentication = true

  admin_ssh_key {
    username   = local.username
    public_key = tls_private_key.example_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account[count.index].primary_blob_endpoint
  }

  tags = { environment = var.environment }
}
