data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_subnet" "app" {
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = var.vnet_name
  name                 = var.subnet_name
}
