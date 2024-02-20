data "azurerm_virtual_network" "hub" {
  resource_group_name = var.hub_vnet.resource_group_name
  name                = var.hub_vnet.name
}

resource "azurerm_virtual_network_peering" "spoke_2_hub" {
  name                      = "${module.app_vnet.vnet_name}-to-${var.hub_vnet.name}"
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = module.app_vnet.vnet_name
  remote_virtual_network_id = data.azurerm_virtual_network.hub.id
}

resource "azurerm_virtual_network_peering" "hub_2_spoke" {
  name                      = "${var.hub_vnet.name}-to-${module.app_vnet.vnet_name}"
  resource_group_name       = var.hub_vnet.resource_group_name
  virtual_network_name      = var.hub_vnet.name
  remote_virtual_network_id = module.app_vnet.vnet_id
}