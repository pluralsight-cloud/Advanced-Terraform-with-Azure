# Create an AKS cluster resource group
resource "azurerm_resource_group" "aks" {
  name     = "${var.prefix}-aks-main"
  location = var.location
}

# Create an AKS cluster
module "cluster" {
  source  = "Azure/aks/azurerm"
  version = "8.0.0"

  # Cluster base config
  resource_group_name        = azurerm_resource_group.aks.name
  prefix                     = var.prefix
  cluster_name_random_suffix = true
  kubernetes_version         = var.kubernetes_version
  sku_tier                   = "Standard"
  node_os_channel_upgrade    = "NodeImage"

  # Cluster system pool
  agents_availability_zones = [1, 2, 3]
  enable_auto_scaling       = true
  agents_max_count          = 4
  agents_min_count          = 3

  # Cluster networking
  vnet_subnet_id = module.spoke_vnet.vnet_subnets_name_id["nodes"]
  network_plugin = "azure"
  network_policy = "calico"

  # Cluster node pools
  node_pools = {
    nodepool1 = {
      name                = lower(substr(var.prefix, 0, 8)) # Max of 8 characters and must be lowercase
      vm_size             = "Standard_DS3_v2"
      enable_auto_scaling = true
      max_count           = 4
      min_count           = 3
      vnet_subnet_id      = module.spoke_vnet.vnet_subnets_name_id["nodes"]
      zones               = [1, 2, 3]
    }
  }

  # Cluster Authentication
  local_account_disabled            = true
  role_based_access_control_enabled = true
  rbac_aad                          = true
  rbac_aad_azure_rbac_enabled       = true
  rbac_aad_managed                  = true
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true


  # Cluster Add-ons
  key_vault_secrets_provider_enabled = true
  attached_acr_id_map = {
    primary = module.containerregistry.resource_id
  }
  green_field_application_gateway_for_ingress = {
    subnet_id = module.spoke_vnet.vnet_subnets_name_id["appgateway"]
  }

  depends_on = [azurerm_resource_group.aks]
}

resource "azurerm_role_assignment" "admin" {
  for_each             = toset(["Azure Kubernetes Service Cluster Admin Role", "Azure Kubernetes Service RBAC Cluster Admin", "Azure Kubernetes Service RBAC Admin"])
  role_definition_name = each.key
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = module.cluster.aks_id
}

resource "azurerm_kubernetes_cluster_extension" "flux" {
  name           = "flux-ext"
  cluster_id     = module.cluster.aks_id
  extension_type = "microsoft.flux"
}

