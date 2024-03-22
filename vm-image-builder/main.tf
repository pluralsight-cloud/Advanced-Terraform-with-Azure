provider "azurerm" {
  features {}
}

# This will create resources for the Azure Image Builder
data "azurerm_client_config" "current" {}

locals {
  base_name = "${var.prefix}-tacoapp-images"
}

# Create a resource group
resource "azurerm_resource_group" "aib" {
  name     = local.base_name
  location = var.location
}

# Create a User Assigned Identity
resource "azurerm_user_assigned_identity" "aib" {
  name                = local.base_name
  resource_group_name = azurerm_resource_group.aib.name
  location            = azurerm_resource_group.aib.location
}

# Create an Azure Role definition
resource "azurerm_role_definition" "aib" {
  name        = local.base_name
  scope       = azurerm_resource_group.aib.id
  description = "Custom role for the Azure Image Builder"

  permissions {
    actions = [
      "Microsoft.Compute/galleries/read",
      "Microsoft.Compute/galleries/images/read",
      "Microsoft.Compute/galleries/images/versions/read",
      "Microsoft.Compute/galleries/images/versions/write",
      "Microsoft.Compute/images/write",
      "Microsoft.Compute/images/read",
      "Microsoft.Compute/images/delete"
    ]
  }

  assignable_scopes = [
    azurerm_resource_group.aib.id,
  ]
}

# Assign the role definition to the user assigned identity
resource "azurerm_role_assignment" "aib" {
  scope              = azurerm_resource_group.aib.id
  role_definition_id = azurerm_role_definition.aib.role_definition_resource_id
  principal_id       = azurerm_user_assigned_identity.aib.principal_id
}

# Create an Azure Computer Gallery
resource "azurerm_shared_image_gallery" "aib" {
  name                = replace(local.base_name, "-", "_")
  resource_group_name = azurerm_resource_group.aib.name
  location            = azurerm_resource_group.aib.location
  description         = "Shared Image Gallery for The Taco Wagon Web Application"
}

# Create an Azure Gallery Image Definition
resource "azurerm_shared_image" "aib" {
  name                = local.base_name
  gallery_name        = azurerm_shared_image_gallery.aib.name
  resource_group_name = azurerm_resource_group.aib.name
  location            = azurerm_resource_group.aib.location
  description         = "Shared Image for The Taco Wagon Web Application"
  os_type             = "Linux"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "Globomantics"
    offer     = "UbuntuTA"
    sku       = "UbuntuTA2004"
  }


}

# Create an image template with the AzAPI provider
# At the time of writing, a resource for the image template is not available
# in the AzureRM provider.
locals {
  imagePublisher = "Canonical"
  imageOffer     = "0001-com-ubuntu-server-focal"
  imageSku       = "20_04-lts-gen2"
  imageVersion   = "latest"
  runOutputName  = "aibLinuxSIG"
}

resource "azapi_resource" "image_templates" {
  type      = "Microsoft.VirtualMachineImages/imageTemplates@2020-02-14"
  name      = "${local.base_name}-template"
  parent_id = azurerm_resource_group.aib.id
  location  = var.location
  depends_on = [
    azurerm_role_assignment.aib
  ]

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.aib.id
    ]
  }

  tags = {
    imagebuilderTemplate = "AzureImageBuilderSIG"
    userIdentity         = "enabled"
  }

  body = jsonencode({
    properties = {
      buildTimeoutInMinutes = 80
      vmProfile = {
        vmSize       = "Standard_D2s_v3"
        osDiskSizeGB = 30
      }
      source = {
        type      = "PlatformImage"
        publisher = local.imagePublisher
        offer     = local.imageOffer
        sku       = local.imageSku
        version   = local.imageVersion
      }
      customize = [
        {
          type      = "Shell"
          name      = "RunScriptFromSource"
          scriptUri = "https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/quickquickstarts/customizeScript.sh"
        },
        {
          type           = "Shell",
          name           = "CheckSumCompareShellScript"
          scriptUri      = "https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/quickquickstarts/customizeScript2.sh"
          sha256Checksum = "ade4c5214c3c675e92c66e2d067a870c5b81b9844b3de3cc72c49ff36425fc93"
        },


        {
          type        = "File"
          name        = "downloadBuildArtifacts"
          sourceUri   = "https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/quickquickstarts/exampleArtifacts/buildArtifacts/index.html"
          destination = "/tmp/index.html"
        },

        {
          type = "Shell"
          name = "setupBuildPath"
          inline = [
            "sudo mkdir /buildArtifacts",
            "sudo cp /tmp/index.html /buildArtifacts/index.html"
          ]
        }
      ]
      distribute = [
        {
          type           = "SharedImage"
          galleryImageId = azurerm_shared_image.aib.id
          runOutputName  = local.runOutputName
          artifactTags = {
            source    = "azureVmImageBuilder"
            baseosimg = "ubuntu2004"
          }
          replicationRegions = [
            var.location
          ]
        }
      ]
    }
  })

  lifecycle {
    ignore_changes = [body]
  }
}

resource "azapi_resource_action" "run_build" {
  type                   = "Microsoft.VirtualMachineImages/imageTemplates@2022-02-14"
  resource_id            = azapi_resource.image_templates.id
  action                 = "run"
  response_export_values = ["*"]

  count = var.build_image ? 1 : 0

  timeouts {
    create = "60m"
  }
}
