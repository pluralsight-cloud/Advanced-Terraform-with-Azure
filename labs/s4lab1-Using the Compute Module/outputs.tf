output "app_subnet_id" {
  value = data.azurerm_subnet.app.id
}

output "public_ip" {
  value = azurerm_public_ip.pip.ip_address
}