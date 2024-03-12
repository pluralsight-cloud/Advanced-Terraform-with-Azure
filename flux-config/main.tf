provider "azurerm" {
  features {

  }
}

resource "azurerm_kubernetes_flux_configuration" "podinfo" {
  name       = "tacopod"
  cluster_id = var.cluster_id
  namespace  = "cluster-config"
  scope      = "cluster"

  git_repository {
    url             = var.flux_git_repo_url
    reference_type  = "branch"
    reference_value = var.flux_git_repo_branch
  }

  kustomizations {
    name = "infra"
    path = "./infrastructure"
  }

  kustomizations {
    name                     = "aspnetapp"
    path                     = "./dotnet"
    sync_interval_in_seconds = 60
  }

}