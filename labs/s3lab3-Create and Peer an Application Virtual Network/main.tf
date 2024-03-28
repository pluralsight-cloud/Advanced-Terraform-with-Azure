locals {
  vnet_name = "${var.naming_prefix}-taconet"
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

module "app_vnet" {
  source  = "Azure/vnet/azurerm"
  version = "4.1.0"
  # insert the 3 required variables here

  resource_group_name = data.azurerm_resource_group.main.name
  vnet_location       = data.azurerm_resource_group.main.location
  use_for_each        = true

  vnet_name       = local.vnet_name
  address_space   = var.vnet_address_space
  subnet_names    = keys(var.subnet_configuration)
  subnet_prefixes = values(var.subnet_configuration)

  tags = var.common_tags
}
