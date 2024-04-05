# Declare the location variable
variable "resource_group_name" {
  description = "Name of provided resource group"
  type        = string
}

# Declare the prefix variable
variable "prefix" {
  description = "The prefix which should be used for all resources"
  type        = string
  default     = "tacowagon"
}

variable "common_tags" {
  description = "Map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "vnet_address_space" {
  description = "List of address spaces to use for the VNET."
  type        = list(string)
}

variable "subnet_configuration" {
  description = "Map of subnets to create in the VNET. Key is subnet name, value is address spaces."
  type        = map(string)
}

variable "kubernetes_version" {
  description = "Version of Kubernetes to use for the AKS cluster."
  type        = string
  default     = null
}