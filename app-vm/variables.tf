variable "location" {
  description = "Location for resource group and virtual machine."
  type        = string
  default     = "eastus"

}

variable "resource_group_name" {
  description = "Name of resource group to create for virtual machine."
  type        = string
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

variable "vm_size" {
  description = "Size of virtual machine to create. Defaults to Standard_F2."
  type        = string
  default     = "Standard_F2"
}

variable "application_port" {
  description = "Port to use for the flask application. Defaults to 80."
  type = number
  default = 80
}

variable "subnet_id" {
  description = "ID of subnet for network interface card of virtual machine."
  type        = string
}

