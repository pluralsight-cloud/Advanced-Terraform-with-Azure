provider "kubernetes" {
  host                   = var.cluster_host
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
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

provider "helm" {
  kubernetes {
    host                   = var.cluster_host
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
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
}

data "azuread_service_principal" "aks" {
  display_name = "Azure Kubernetes Service AAD Server"
}

resource "kubernetes_namespace" "argo" {
  metadata {
    name = var.argo_namespace
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "6.4.0"
  namespace  = var.argo_namespace
  timeout    = "1200"
  values     = [templatefile("./argocd/install.yaml", {})]

  depends_on = [kubernetes_namespace.argo]
}

data "kubernetes_secret" "argo" {
  metadata {
    name = "argocd-initial-admin-secret"
    namespace = var.argo_namespace
  }
}