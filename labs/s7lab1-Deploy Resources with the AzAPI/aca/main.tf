data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "random_integer" "main" {
  min = 10000
  max = 99999
}

resource "azurerm_storage_account" "main" {
  name                      = "tacowagon${random_integer.main.result}"
  resource_group_name       = data.azurerm_resource_group.main.name
  location                  = data.azurerm_resource_group.main.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  blob_properties {
    last_access_time_enabled = true
  }
}

resource "azapi_update_resource" "local_user" {
  type        = "Microsoft.Storage/storageAccounts@2021-09-01"
  resource_id = azurerm_storage_account.main.id

  body = jsonencode({
    properties = {
      isLocalUserEnabled = false
    }
  })
}

resource "azapi_resource" "cold_storage_policy" {
  type      = "Microsoft.Storage/storageAccounts/managementPolicies@2023-01-01"
  name      = "default"
  parent_id = azurerm_storage_account.main.id

  body = jsonencode({
    properties = {
      policy = {
        rules = [
          {
            name    = "default"
            enabled = true
            type    = "Lifecycle"
            definition = {
              filters = {
                blobTypes = ["blockBlob"]
              }
              actions = {
                baseBlob = {
                  tierToCold = {
                    daysAfterLastAccessTimeGreaterThan = 90
                  }
                  tierToCool = {
                    daysAfterLastAccessTimeGreaterThan = 365
                  }
                }
              }
            }
          }
      ] }
    }
  })
}