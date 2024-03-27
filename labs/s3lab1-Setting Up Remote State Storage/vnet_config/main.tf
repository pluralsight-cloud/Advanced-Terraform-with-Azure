provider "azurerm" {
  features {}
  skip_provider_registration = true
  storage_use_azuread        = true
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group provided by the lab."
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "main" {
  name                = "taco-wagon-app"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location

  address_space = ["10.42.0.0/24"]
}