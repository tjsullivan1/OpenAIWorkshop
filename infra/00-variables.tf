variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "East US"
  validation {
    condition = contains([
      "East US", "East US 2", "West US", "West US 2", "West US 3",
      "Central US", "North Central US", "South Central US", "West Central US",
      "Canada Central", "Canada East",
      "North Europe", "West Europe", "UK South", "UK West",
      "France Central", "Germany West Central", "Switzerland North",
      "Southeast Asia", "East Asia", "Australia East", "Australia Southeast",
      "Japan East", "Japan West", "Korea Central", "Korea South",
      "India Central", "India South", "India West"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-openai-workshop"
}

variable "ai_hub_name" {
  description = "Name of the Azure AI Foundry Hub"
  type        = string
  default     = "aihub-openai-workshop"
}

variable "ai_project_name" {
  description = "Name of the Azure AI Foundry Project"
  type        = string
  default     = "aiproject-openai-workshop"
}

variable "openai_deployment_name" {
  description = "Name of the OpenAI model deployment"
  type        = string
  default     = "gpt-4o"
}

variable "openai_model_name" {
  description = "OpenAI model name to deploy"
  type        = string
  default     = "gpt-4o"
}

variable "openai_model_version" {
  description = "OpenAI model version"
  type        = string
  default     = "2024-08-06"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "OpenAI-Workshop"
    ManagedBy   = "Terraform"
  }
}
