variable "resource_group_name" {
  type        = string
  description = "Name of the resource group provided by the lab."
}

variable "naming_prefix" {
  description = "Prefix to use for naming of resources."
  type        = string
}

variable "common_tags" {
  description = "Map of tags to apply to all resources."
  type        = map(string)
}

variable "vnet_address_space" {
  description = "List of address spaces to use for the VNET."
  type        = list(string)
}

variable "subnet_configuration" {
  description = "Map of subnets to create in the VNET. Key is subnet name, value is address spaces."
  type        = map(string)
}
