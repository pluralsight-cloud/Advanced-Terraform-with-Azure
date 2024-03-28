data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_subnet" "app" {
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = var.vnet_name
  name                 = var.subnet_name
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "azurerm_public_ip" "pip" {

  allocation_method   = "Static"
  location            = data.azurerm_resource_group.main.location
  name                = "pip-${var.vm_name}"
  resource_group_name = data.azurerm_resource_group.main.name
  sku                 = "Standard"
}

module "linux" {
  source  = "Azure/virtual-machine/azurerm"
  version = "1.1.0"

  location                   = data.azurerm_resource_group.main.location
  image_os                   = "linux"
  resource_group_name        = data.azurerm_resource_group.main.name
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
  size      = "Standard_F2"
  subnet_id = data.azurerm_subnet.app.id

  custom_data = base64encode(templatefile("${path.module}/custom_data.tpl", {
    admin_username = var.admin_username
    port           = var.application_port
  }))

}

resource "azurerm_network_security_group" "app_vm" {
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  name                = "nsg-${var.vm_name}"
}

resource "azurerm_network_security_rule" "http" {
  network_security_group_name = azurerm_network_security_group.app_vm.name
  resource_group_name         = azurerm_network_security_group.app_vm.resource_group_name
  name                        = "http"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = var.application_port
  destination_address_prefix  = "*"
}

resource "azurerm_network_interface_security_group_association" "app_vm" {
  network_interface_id      = module.linux.network_interface_id
  network_security_group_id = azurerm_network_security_group.app_vm.id
}