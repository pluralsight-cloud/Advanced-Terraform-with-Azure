data "terraform_remote_state" "aks" {
  backend = "local"

  config = {
    path = "../aks_cluster/terraform.tfstate"
  }
}

resource "kubernetes_manifest" "flux_source" {
  manifest = {
    apiVersion = "source.toolkit.fluxcd.io/v1"
    kind       = "GitRepository"
    metadata = {
      name      = "sampleapp"
      namespace = "flux-system"
    }

    spec = {
      interval = "1m"
      ref = {
        branch = var.flux_git_repo_branch
      }
      url = var.flux_git_repo_url
    }
  }
}

resource "kubernetes_manifest" "flux_infra" {
  manifest = {
    apiVersion = "kustomize.toolkit.fluxcd.io/v1"
    kind       = "Kustomization"
    metadata = {
      name      = "infra"
      namespace = "flux-system"
    }

    spec = {
      path = "./infrastructure"
      interval = "30m"
      sourceRef = {
        kind = "GitRepository"
        name = "sampleapp"
      }
      prune = true
    }
  }
}

resource "kubernetes_manifest" "flux_app" {
  manifest = {
    apiVersion = "kustomize.toolkit.fluxcd.io/v1"
    kind       = "Kustomization"
    metadata = {
      name      = "dotnetapp"
      namespace = "flux-system"
    }

    spec = {
      path     = "./dotnet-lb"
      interval = "1m"
      sourceRef = {
        kind = "GitRepository"
        name = "sampleapp"
      }
      prune = true
    }
  }
}