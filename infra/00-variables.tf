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

variable "app_location" {
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
    ], var.app_location)
    error_message = "Location must be a valid Azure region."
  }
}



# Project prefix and stage for naming
variable "project_prefix" {
  description = "Prefix for all resource names (e.g. 'openaiworkshop')"
  type        = string
  default     = "openaiworkshop"
}

variable "project_stage" {
  description = "Deployment stage (e.g. 'dev', 'prod', 'test')"
  type        = string
  default     = "dev"
}

variable "openai_deployment_name" {
  description = "Name of the OpenAI model deployment"
  type        = string
  default     = "gpt-4.1"
}

variable "openai_model_name" {
  description = "OpenAI model name to deploy"
  type        = string
  default     = "gpt-4.1"
}

variable "openai_model_version" {
  description = "OpenAI model version"
  type        = string
  default     = "2025-04-14"
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

variable "created_date" {
  description = "Creation date for resources (set once, prevents timestamp updates)"
  type        = string
  default     = null
}

variable "https_only" {
  description = "Should the web app only accept HTTPS requests"
  type        = bool
  default     = true
}

variable "always_on" {
  description = "Should the web app be always on (not applicable for Free tier)"
  type        = bool
  default     = true
}


variable "docker_image_backend" {
  description = "Docker image name (e.g., 'nginx:latest', 'httpd:alpine'). Leave empty to use runtime stack instead."
  type        = string
  default     = ""
}

variable "docker_image_mcp" {
  description = "Docker image name (e.g., 'nginx:latest', 'httpd:alpine'). Leave empty to use runtime stack instead."
  type        = string
  default     = ""
}

variable "docker_registry_url" {
  description = "Docker registry URL (e.g., 'https://index.docker.io' for Docker Hub). Only needed for private registries."
  type        = string
  default     = ""
}

variable "docker_registry_username" {
  description = "Username for private Docker registry authentication"
  type        = string
  default     = ""
  sensitive   = true
}

variable "docker_registry_password" {
  description = "Password for private Docker registry authentication"
  type        = string
  default     = ""
  sensitive   = true
}
