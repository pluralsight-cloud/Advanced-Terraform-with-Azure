# Create an AKS cluster
module "app" {
  source  = "Azure/aks/azurerm"
  version = "8.0.0"

  # Cluster base config
  resource_group_name             = data.azurerm_resource_group.main.name
  prefix                          = var.prefix
  cluster_name_random_suffix      = true
  kubernetes_version              = var.kubernetes_version
  sku_tier                        = "Standard"
  node_os_channel_upgrade         = "NodeImage"
  automatic_channel_upgrade       = "node-image"
  log_analytics_workspace_enabled = false

  # Cluster system pool
  enable_auto_scaling = false
  agents_count        = 2
  agents_size         = "Standard_D2s_v3"
  agents_pool_name    = "systempool"

  # Cluster networking
  vnet_subnet_id = module.aks_vnet.vnet_subnets_name_id["nodes"]
  network_plugin = "azure"
  network_policy = "azure"

  # Cluster node pools
  node_pools = {
    apppool1 = {
      name           = lower(substr(var.prefix, 0, 8)) # Max of 8 characters and must be lowercase
      vm_size        = "Standard_D2s_v3"
      node_count     = 1
      vnet_subnet_id = module.aks_vnet.vnet_subnets_name_id["nodes"]
    }
  }

  # Cluster Authentication
  local_account_disabled            = false
  role_based_access_control_enabled = true
  rbac_aad                          = false

}

resource "helm_release" "flux" {
  repository       = "https://fluxcd-community.github.io/helm-charts"
  chart            = "flux2"
  name             = "flux2"
  namespace        = "flux-system"
  create_namespace = true
}