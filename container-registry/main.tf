provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-taco-warehouse"
  location = var.location
}

resource "azurerm_container_registry" "main" {
  name                = "${var.prefix}tacoapp"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Premium"
  admin_enabled       = false

  #retention_policy {
  #  enabled = true
  #  days = 14
  #}
}


resource "azapi_update_resource" "retention_policy" {
  type        = "Microsoft.ContainerRegistry/registries@2023-01-01-preview"
  resource_id = azurerm_container_registry.main.id

  body = jsonencode({
    properties = {
      policies = {
        retentionPolicy = {
          days   = 14
          status = "enabled"
        }
      }
    }
  })
}