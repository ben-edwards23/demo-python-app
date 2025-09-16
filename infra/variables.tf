variable "location" {
  type        = string
  description = "Azure region"
  default     = "uksouth"
}

variable "name_prefix" {
  type        = string
  description = "Short prefix for resource names (e.g., benflask01)"
}

variable "resource_group_name" {
  type        = string
  description = "Name for the Resource Group"
}

variable "webapp_name" {
  type        = string
  description = "Explicit Web App name (optional)"
  default     = ""
}

variable "acr_name" {
  type        = string
  description = "Explicit ACR name (must be globally unique, optional)"
  default     = ""
}

variable "plan_sku" {
  type        = string
  description = "App Service Plan SKU (e.g., B1, P1v3)"
  default     = "F1"
}

variable "acr_sku" {
  type        = string
  description = "ACR SKU: Basic, Standard, or Premium"
  default     = "Standard"
}

variable "tags" {
  type        = map(string)
  description = "Extra tags"
  default     = { CreatedBy = "Terraform" }
}
