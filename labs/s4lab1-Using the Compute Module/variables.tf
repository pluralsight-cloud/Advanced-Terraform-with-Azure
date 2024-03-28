variable "resource_group_name" {
  description = "Name of resource group provided by the lab."
  type        = string
}

variable "vnet_name" {
  description = "Name of the Virtual Network provided by the lab."
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet to use in the Virtual Network. Defaults to app."
  type        = string
  default     = "app"
}

variable "vm_name" {
  description = "Name of virtual machine to create."
  type        = string
}

variable "admin_username" {
  description = "Admin username for virtual machine. Defaults to azureuser."
  type        = string
  default     = "azureuser"
}

variable "application_port" {
  description = "Port to use for the flask application. Defaults to 80."
  type        = number
  default     = 80
}