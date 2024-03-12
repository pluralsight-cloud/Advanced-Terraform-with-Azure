provider "kubernetes" {
  host                   = module.cluster.host
  cluster_ca_certificate = base64decode(module.cluster.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args = [
      "get-token",
      "--login",
      "azurecli",
      "--environment",
      "AzurePublicCloud",
      "--server-id",
      data.azuread_service_principal.aks.client_id
    ]
  }
}

data "azuread_service_principal" "aks" {
  display_name = "Azure Kubernetes Service AAD Server"
}

resource "kubernetes_service_account_v1" "workload_identity" {
  metadata {
    name      = local.wi_sa_name
    namespace = local.wi_namespace
    annotations = {
      "azure.workload.identity/client-id" = azurerm_user_assigned_identity.vault.client_id
    }
  }

  depends_on = [ azurerm_role_assignment.admin ]
}