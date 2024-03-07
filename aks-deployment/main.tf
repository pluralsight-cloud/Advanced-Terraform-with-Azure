# Provider config
provider "azurerm" {
  features {}
}

# Create resource group for networking
resource "azurerm_resource_group" "network" {
  name     = "${var.prefix}-aks-spoke"
  location = var.location
}

# Create virtual network with subnets
module "spoke_vnet" {
  source  = "Azure/vnet/azurerm"
  version = "4.1.0"

  resource_group_name = azurerm_resource_group.network.name
  vnet_location       = azurerm_resource_group.network.location
  use_for_each        = true

  vnet_name       = azurerm_resource_group.network.name
  address_space   = var.vnet_address_space
  subnet_names    = keys(var.subnet_configuration)
  subnet_prefixes = values(var.subnet_configuration)

  tags = var.common_tags

}


# Create an AKS cluster resource group
resource "azurerm_resource_group" "aks" {
  name     = "${var.prefix}-aks-main"
  location = var.location
}

# Create an AKS cluster
module "cluster" {
  source  = "Azure/aks/azurerm"
  version = "8.0.0"

  resource_group_name       = azurerm_resource_group.aks.name
  prefix                    = var.prefix
  agents_availability_zones = [1, 2, 3]
  enable_auto_scaling       = true
  agents_max_count          = 4
  agents_min_count          = 3
  vnet_subnet_id            = module.spoke_vnet.vnet_subnets_name_id["nodes"]
  node_pools = {
    nodepool1 = {
      name                = "${var.prefix}-pool"
      vm_size             = "Standard_DS3_v2"
      enable_auto_scaling = true
      max_count           = 4
      min_count           = 3
      vnet_subnet_id      = module.spoke_vnet.vnet_subnets_name_id["nodes"]
      zones               = [1, 2, 3]
    }
  }
  key_vault_secrets_provider_enabled = true
  kubernetes_version                 = var.kubernetes_version
  local_account_disabled             = true
  network_plugin                     = "azure"
  network_plugin_mode                = "Overlay"
  network_policy                     = "calico"
  node_os_channel_upgrade            = "NodeImage"
  private_dns_zone_id                = "System"
  rbac_aad                           = true
  rbac_aad_azure_rbac_enabled        = true
  rbac_aad_managed                   = true
  sku_tier                           = "Standard"
  workload_identity_enabled          = true




}