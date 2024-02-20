provider "azurerm" {
  features {}
  
}

import {
  id = "/subscriptions/7d647b65-93d0-4240-a0be-37dcbaca013d/resourceGroups/hub-networking/providers/Microsoft.Network/virtualNetworks/hub-eastus"
  to = azurerm_virtual_network.main
}

import {
  id = "/subscriptions/7d647b65-93d0-4240-a0be-37dcbaca013d/resourceGroups/hub-networking/providers/Microsoft.Network/virtualNetworks/hub-eastus/subnets/main"
  to = azurerm_subnet.main
}

import {
  id = "/subscriptions/7d647b65-93d0-4240-a0be-37dcbaca013d/resourceGroups/hub-networking/providers/Microsoft.Network/virtualNetworks/hub-eastus/subnets/security"
  to = azurerm_subnet.security
}
