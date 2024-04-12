provider "azurerm" {
  features {}
  skip_provider_registration = true
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "random_integer" "main" {
  max = 99999
  min = 10000
}

locals {
  agent_name = "azp-agent-${random_integer.main.result}"
}

resource "azurerm_container_group" "main" {
  name                = local.agent_name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  ip_address_type     = "Public"
  dns_name_label      = local.agent_name
  os_type             = "Linux"
  container {
    name   = "azp-agent"
    image  = "ned1313/azp-agent:1.2.0"
    cpu    = "1.0"
    memory = "2.0"
    ports {
      port = 80
      protocol = "TCP"
    }
    environment_variables = {
      AZP_URL        = var.azp_url
      AZP_TOKEN      = var.azp_token
      AZP_POOL       = var.azp_pool
      AZP_AGENT_NAME = local.agent_name
    }
  }

}

output "dns_hostname" {
  value = azurerm_container_group.main.fqdn
}