data "azurerm_resource_group" "vmss" {
  name = var.resource_group_name
}

data "azurerm_subnet" "web" {
  resource_group_name  = data.azurerm_resource_group.vmss.name
  virtual_network_name = var.vnet_name
  name                 = var.subnet_name
}
