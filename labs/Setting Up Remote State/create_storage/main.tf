provider "azurerm" {
  features {}
  skip_provider_registration = true
  storage_use_azuread        = true
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "random_integer" "main" {
  min = 10000
  max = 99999
}

resource "azurerm_storage_account" "main" {
  name                = "${lower(var.prefix)}taco${random_integer.main.result}"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  account_tier                      = "Standard"
  account_kind                      = "StorageV2"
  account_replication_type          = "GRS"
  enable_https_traffic_only         = true
  min_tls_version                   = "TLS1_2"
  shared_access_key_enabled         = false
  default_to_oauth_authentication   = true
  infrastructure_encryption_enabled = false


  blob_properties {
    versioning_enabled            = true
    change_feed_enabled           = true
    change_feed_retention_in_days = 90
    last_access_time_enabled      = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }

  }

  sas_policy {
    expiration_period = "00.02:00:00"
    expiration_action = "Log"
  }

  timeouts {
    create = "5m"
    read   = "5m"
  }

}


# Create a container in storage account
resource "azurerm_storage_container" "main" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}