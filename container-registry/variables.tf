variable "prefix" {
  description = "Naming prefix for resources. No default."
  type        = string
}

variable "location" {
  description = "Region for resource deployment. Defaults to eastus."
  type        = string
  default     = "eastus"
}

variable "blob_retention_days" {
  description = "Retention period for blob change feed in days. Defaults to 14."
  type        = number
  default     = 14
}