# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform
resource "azurerm_virtual_network" "main" {
  address_space           = ["10.42.0.0/16"]
  bgp_community           = null
  dns_servers             = []
  edge_zone               = null
  location                = "eastus"
  name                    = "hub-eastus"
  resource_group_name     = "hub-networking"
  tags = {}
}

# __generated__ by Terraform
resource "azurerm_subnet" "security" {
  address_prefixes                              = ["10.42.1.0/24"]
  name                                          = "security"
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = true
  resource_group_name                           = "hub-networking"
  service_endpoints                             = []
  virtual_network_name                          = azurerm_virtual_network.main.name
}

# __generated__ by Terraform
resource "azurerm_subnet" "main" {
  address_prefixes                              = ["10.42.0.0/24"]
  name                                          = "main"
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = true
  resource_group_name                           = "hub-networking"
  service_endpoints                             = []
  virtual_network_name                          = azurerm_virtual_network.main.name
}
