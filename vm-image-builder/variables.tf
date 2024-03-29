variable "location" {
  type        = string
  description = "(Optional) The Azure region where the resources should be created."
  default     = "eastus"
}

variable "prefix" {
  type        = string
  description = "(Optional) The prefix for the name of the resources."
  default     = "dev"
}

variable "build_image" {
  type        = bool
  description = "(Optional) Whether to run a build of the image template. Defaults to false"
  default     = false
}