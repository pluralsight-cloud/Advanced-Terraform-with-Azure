provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {

  location = var.location
  name     = var.resource_group_name
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "azurerm_public_ip" "pip" {

  allocation_method   = "Static"
  location            = azurerm_resource_group.rg.location
  name                = "pip-${var.vm_name}"
  resource_group_name = azurerm_resource_group.rg.name
  sku = "Standard"
}

module "linux" {
  source  = "Azure/virtual-machine/azurerm"
  version = "1.1.0"

  location                   = azurerm_resource_group.rg.location
  image_os                   = "linux"
  resource_group_name        = azurerm_resource_group.rg.name
  allow_extension_operations = false
  boot_diagnostics           = true
  new_network_interface = {
    ip_forwarding_enabled = false
    ip_configurations = [
      {
        public_ip_address_id = azurerm_public_ip.pip.id
        primary              = true
      }
    ]
  }
  admin_username = var.admin_username
  admin_ssh_keys = [
    {
      public_key = tls_private_key.ssh.public_key_openssh
    }
  ]
  name = var.vm_name
  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  os_simple = "UbuntuServer"
  size      = var.vm_size
  subnet_id = var.subnet_id

  user_data = base64encode(templatefile("${path.module}/templates/custom_data.tpl", {
    admin_username = var.admin_username
    port           = var.application_port
  }))

}

resource "azurerm_network_security_group" "app_vm" {
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  name = "nsg-${var.vm_name}"
}

resource "azurerm_network_security_rule" "http" {
  network_security_group_name = azurerm_network_security_group.app_vm.name
  resource_group_name = azurerm_network_security_group.app_vm.resource_group_name
  name = "http"
  priority = 100
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  source_address_prefix = "*"
  destination_port_range = "${var.application_port}"
  destination_address_prefix = "*"
}

resource "azurerm_network_interface_security_group_association" "app_vm" {
  network_interface_id = module.linux.network_interface_id
  network_security_group_id = azurerm_network_security_group.app_vm.id
}

resource "local_file" "ssh_private_key" {
  filename = "${path.module}/key.pem"
  content  = tls_private_key.ssh.private_key_pem
}