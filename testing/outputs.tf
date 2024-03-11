output "agro_install" {
  value = base64decode(data.kubernetes_secret.argo.data.password)
}