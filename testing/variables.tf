variable "cluster_host" {
  type        = string
  description = "AKS Cluster Host address where Argo will be installed"
}

variable "cluster_ca_certificate" {
  type        = string
  description = "AKS Cluster CA Certificate where Argo will be installed"
}

variable "argo_namespace" {
  type        = string
  description = "Namespace to use for Argo installation. Defaults to argo"
  default     = "argo"
}