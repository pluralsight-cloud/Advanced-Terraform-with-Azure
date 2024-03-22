# Create a Key Vault with private link endpoint in subnet
data "azurerm_client_config" "current" {}

resource "azurerm_private_dns_zone" "vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.aks.name
}

resource "azurerm_user_assigned_identity" "vault" {
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  name                = "${var.prefix}-aks-ua"
}

module "avm-res-keyvault-vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.5.2"

  name                = "${var.prefix}-aks-app"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  private_endpoints = {
    primary = {
      subnet_resource_id            = module.spoke_vnet.vnet_subnets_name_id["privatelink"]
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.vault.id]
    }
  }
  public_network_access_enabled = false
  role_assignments = {
    vault_provider = {
      role_definition_id_or_name       = "Key Vault Administrator"
      principal_id                     = module.cluster.key_vault_secrets_provider.secret_identity[0].object_id
      skip_service_principal_aad_check = true
    }
    workload_identity = {
      role_definition_id_or_name       = "Key Vault Administrator"
      principal_id                     = azurerm_user_assigned_identity.vault.client_id
      skip_service_principal_aad_check = true
    }
  }

}

resource "azurerm_federated_identity_credential" "vault" {
  name                = "wi-kv-aks"
  resource_group_name = azurerm_resource_group.aks.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.cluster.oidc_issuer_url
  subject             = "system:serviceaccount:${local.wi_namespace}:${local.wi_sa_name}"
  parent_id           = azurerm_user_assigned_identity.vault.id
}
