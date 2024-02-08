provider "azurerm" {
  features {}
}

locals {
  resource_group_name = "${var.naming_prefix}-tacotruck"
  vnet_name           = "${var.naming_prefix}-taconet"
}

resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location

  tags = var.common_tags
}