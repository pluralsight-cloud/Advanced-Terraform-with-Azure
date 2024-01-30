# Create a public ip address
resource "azurerm_public_ip" "nat" {
  name                = module.app_vnet.vnet_name
  allocation_method   = "Static"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  tags = var.common_tags
}

# Create a NAT GW
resource "azurerm_nat_gateway" "nat" {
  name                = module.app_vnet.vnet_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "Standard"
}

# Associate Public IP
resource "azurerm_nat_gateway_public_ip_association" "nat" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

# Associate subnets
resource "azurerm_subnet_nat_gateway_association" "nat" {
  for_each       = module.app_vnet.vnet_subnets_name_id
  nat_gateway_id = azurerm_nat_gateway.nat.id
  subnet_id      = each.value
}