variable "resource_group_name" {
  type        = string
  description = "Name of the resource group provided by the lab."
}

variable "azp_url" {
  description = "URL of your Azure DevOps Organization in the form https://dev.azure.com/YOURORGNAME"
  type        = string
}

variable "azp_token" {
  description = "Personal access token for your Azure DevOps Organziation."
  type        = string
}

variable "azp_pool" {
  description = "Name of the agent pool you created in Azure DevOps."
  type        = string
  default     = "aci-agents"
}