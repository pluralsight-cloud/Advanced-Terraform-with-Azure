variable "resource_group_name" {
  type        = string
  description = "Name of the resource group provided by the lab."
}

variable "prefix" {
  type        = string
  description = "Prefix to be used for all resources in this lab."
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "azurerm_container_group" "main" {
  name                = "${var.prefix}-container-group"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  ip_address_type     = "Public"
  dns_name_label      = "${var.prefix}-container-group"
  os_type             = "Linux"
  container {
    name   = "hello-world"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld"
    cpu    = "0.5"
    memory = "1.5"
    ports {
      port     = 80
      protocol = "TCP"
    }
  }
}

output "dns_hostname" {
  value = azurerm_container_group.main.fqdn
}