variable "prefix" {
  description = "Naming prefix for resources. Should be 3-8 characters."
  type        = string
  default     = "tacoweb"

  validation {
    condition     = length(var.prefix) >= 3 && length(var.prefix) <= 8
    error_message = "Naming prefix should be between 3-8 characters. Submitted value was ${length(var.prefix)}."
  }
}

variable "location" {
  description = "Location for resource group."
  type        = string
  default     = "eastus"

}

variable "vmss_count" {
  description = "Starting number of VMSS instances to create. Defaults to 2."
  type        = number
  default     = 2

  validation {
    condition     = var.vmss_count >= 1
    error_message = "Count must be 1 or greater. Submitted value was ${var.vmss_count}."
  }
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
  type        = number
  default     = 80
}

variable "subnet_id" {
  description = "ID of subnet for network interface card of virtual machine."
  type        = string
}

variable "api_key" {
  type = string
}

