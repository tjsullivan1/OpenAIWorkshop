# Output Values
# Expose important resource information for integration and reference

# Resource Group
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

output "resource_group_id" {
  description = "ID of the created resource group"
  value       = azurerm_resource_group.main.id
}

# Azure AI Hub
output "ai_hub_name" {
  description = "Name of the Azure AI Hub (Machine Learning Workspace)"
  value       = azurerm_ai_services.ai_hub.name
}

output "ai_hub_id" {
  description = "ID of the Azure AI Hub"
  value       = azurerm_ai_services.ai_hub.id
}

# output "ai_hub_workspace_id" {
#   description = "Workspace ID of the Azure AI Hub"
#   value       = azurerm_machine_learning_workspace.ai_hub.workspace_id
# }

# Azure OpenAI
output "openai_account_name" {
  description = "Name of the Azure OpenAI account"
  value       = azurerm_cognitive_deployment.gpt.name
}

output "openai_endpoint" {
  description = "Endpoint URL for the Azure OpenAI service"
  value       = azurerm_ai_services.ai_hub.endpoint
}

output "openai_deployment_name" {
  description = "Name of the OpenAI model deployment"
  value       = azurerm_cognitive_deployment.gpt.name
}

# # Storage Account
# output "storage_account_name" {
#   description = "Name of the storage account"
#   value       = azurerm_storage_account.ai_storage.name
# }

# output "storage_account_primary_blob_endpoint" {
#   description = "Primary blob endpoint of the storage account"
#   value       = azurerm_storage_account.ai_storage.primary_blob_endpoint
# }

# Key Vault
output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

# # Application Insights
# output "application_insights_name" {
#   description = "Name of Application Insights"
#   value       = azurerm_application_insights.main.name
# }

# output "application_insights_instrumentation_key" {
#   description = "Instrumentation key for Application Insights"
#   value       = azurerm_application_insights.main.instrumentation_key
#   sensitive   = true
# }

# output "application_insights_connection_string" {
#   description = "Connection string for Application Insights"
#   value       = azurerm_application_insights.main.connection_string
#   sensitive   = true
# }

# App Services
output "backend_app_service_name" {
  description = "Name of the backend App Service"
  value       = azurerm_linux_web_app.backend.name
}

output "backend_app_service_url" {
  description = "URL of the backend App Service"
  value       = "https://${azurerm_linux_web_app.backend.default_hostname}"
}

output "mcp_app_service_name" {
  description = "Name of the MCP App Service"
  value       = azurerm_linux_web_app.mcp.name
}

output "mcp_app_service_url" {
  description = "URL of the MCP App Service"
  value       = "https://${azurerm_linux_web_app.mcp.default_hostname}"
}

output "backend_managed_identity_principal_id" {
  description = "Principal ID of the backend App Service managed identity"
  value       = azurerm_linux_web_app.backend.identity[0].principal_id
}

output "mcp_managed_identity_principal_id" {
  description = "Principal ID of the MCP App Service managed identity"
  value       = azurerm_linux_web_app.mcp.identity[0].principal_id
}