provider "azurerm" {
  features {}
}

import {
  to = azurerm_virtual_network.main
  id = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/vnet-import/providers/Microsoft.Network/virtualNetworks/hub-useast"
}

import {
  to = azurerm_subnet.main
  id = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/vnet-import/providers/Microsoft.Network/virtualNetworks/hub-useast/subnets/main"
}

import {
  to = azurerm_subnet.security
  id = "/subscriptions/4d8e572a-3214-40e9-a26f-8f71ecd24e0d/resourceGroups/vnet-import/providers/Microsoft.Network/virtualNetworks/hub-useast/subnets/security"
}