# Main Infrastructure Resources
# Core Azure resources for the OpenAI Workshop

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_ai_services" "ai_hub" {
  custom_subdomain_name              = local.ai_hub_name
  fqdns                              = []
  local_authentication_enabled       = true
  location                           = var.location
  name                               = local.ai_hub_name
  outbound_network_access_restricted = false
  public_network_access              = "Enabled"
  resource_group_name                = azurerm_resource_group.main.name
  sku_name                           = "S0"
  tags                               = local.common_tags

  identity {
    identity_ids = []
    type         = "SystemAssigned"
  }

  network_acls {
    default_action = "Allow"
    ip_rules       = []
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Key Vault
# To reference secrets in App Service app settings, use the format:
# @Microsoft.KeyVault(SecretUri=https://<keyvault-name>.vault.azure.net/secrets/<secret-name>/<version>)
# Or without version: @Microsoft.KeyVault(SecretUri=https://<keyvault-name>.vault.azure.net/secrets/<secret-name>/)
# Example: "@Microsoft.KeyVault(SecretUri=https://kv-example.vault.azure.net/secrets/DatabasePassword/)"
resource "azurerm_key_vault" "main" {
  name                       = local.key_vault_name
  location                   = var.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  # Enable RBAC authorization (recommended over access policies)
  rbac_authorization_enabled = true

  # Network settings
  public_network_access_enabled = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }

  tags = local.common_tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# Key Vault Role Assignment - Current User (Key Vault Administrator)
resource "azurerm_role_assignment" "kv_admin_current_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Key Vault Role Assignment - Backend App (Key Vault Secrets User)
resource "azurerm_role_assignment" "kv_secrets_backend" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.backend.identity[0].principal_id

  depends_on = [azurerm_linux_web_app.backend]
}

# Key Vault Role Assignment - MCP App (Key Vault Secrets User)
resource "azurerm_role_assignment" "kv_secrets_mcp" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.mcp.identity[0].principal_id

  depends_on = [azurerm_linux_web_app.mcp]
}

resource "azurerm_key_vault_secret" "aoai_endpoint" {
name = "AZURE-OPENAI-ENDPOINT"
value = azurerm_ai_services.ai_hub.endpoint
key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "aoai_api_key" {
name = "AZURE-OPENAI-API-KEY"
value = azurerm_ai_services.ai_hub.primary_access_key
key_vault_id = azurerm_key_vault.main.id
}


resource "azurerm_service_plan" "main" {
  name                = "asp-${local.web_app_name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.app_location
  os_type             = "Linux"
  sku_name            = "P2v3"
}

# Web Apps
resource "azurerm_linux_web_app" "backend" {

  name                = "wa-${local.web_app_name_prefix}-backend"
  location            = var.app_location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id

  # Security settings
  https_only                                     = var.https_only
  client_affinity_enabled                        = false
  client_certificate_enabled                     = false
  client_certificate_mode                        = "Required"
  public_network_access_enabled                  = true
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false

  # App settings - can be customized per app if needed
  app_settings = merge(var.tags, {
    "AZURE_OPENAI_ENDPOINT"="@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.aoai_endpoint.id})",
    "AZURE_OPENAI_API_KEY"="@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.aoai_api_key.id})",
    "AZURE_OPENAI_API_VERSION"=azurerm_cognitive_deployment.gpt.model[0].version,
    "AZURE_OPENAI_EMBEDDING_DEPLOYMENT"="text-embedding-ada-002",
    "DB_PATH"="data/contoso.db",
    "AAD_TENANT_ID"="",
    "MCP_API_AUDIENCE"="",
    "AGENT_MODULE"="agents.autogen.single_agent.loop_agent",
    "MCP_SERVER_URI"="https://${azurerm_linux_web_app.mcp.default_hostname}/mcp",
    "DISABLE_AUTH"="true",
    "WEBSITES_PORT"="7000"
  })

  tags = var.tags

  # Enable System Assigned Managed Identity
  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on = var.always_on

    # Security settings
    ftps_state          = "FtpsOnly"
    http2_enabled       = true
    minimum_tls_version = "1.2"

    # Performance settings
    load_balancing_mode = "LeastRequests"
    use_32_bit_worker   = false
    worker_count        = 1

    # Health check
    # health_check_eviction_time_in_min = 0

    # Default documents
    default_documents = [
      "Default.htm",
      "Default.html",
      "Default.asp",
      "index.htm",
      "index.html",
      "iisstart.htm",
      "default.aspx",
      "index.php",
      "hostingstart.html"
    ]

    application_stack {
      # Docker configuration (takes precedence if docker_image is specified)
      docker_image_name        = var.docker_image_backend
      docker_registry_url      = var.docker_registry_url
      docker_registry_username = var.docker_registry_username
      docker_registry_password = var.docker_registry_password
    }
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to these as they may be modified by deployments
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      zip_deploy_file
    ]
  }
}

resource "azurerm_linux_web_app" "mcp" {

  name                = "wa-${local.web_app_name_prefix}-mcp"
  location            = var.app_location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id

  # Security settings
  https_only                                     = var.https_only
  client_affinity_enabled                        = false
  client_certificate_enabled                     = false
  client_certificate_mode                        = "Required"
  public_network_access_enabled                  = true
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false

  # App settings - can be customized per app if needed
  app_settings = merge(var.tags, {
    "WEBSITE_RUN_FROM_PACKAGE" = "1",
    "AZURE_OPENAI_ENDPOINT"="@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.aoai_endpoint.id})",
    "AZURE_OPENAI_API_KEY"="@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.aoai_api_key.id})",
    "AZURE_OPENAI_API_VERSION"=azurerm_cognitive_deployment.gpt.model[0].version,
    "AZURE_OPENAI_EMBEDDING_DEPLOYMENT"="text-embedding-ada-002",
    "DB_PATH"="data/contoso.db",
    "AAD_TENANT_ID"="",
    "MCP_API_AUDIENCE"="",
    "MCP_SERVER_URI"="http://localhost:7000/mcp",
    "DISABLE_AUTH"="true",
    "WEBSITES_PORT"="8000"
  })

  tags = var.tags

  # Enable System Assigned Managed Identity
  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on = var.always_on

    # Security settings
    ftps_state          = "FtpsOnly"
    http2_enabled       = true
    minimum_tls_version = "1.2"

    # Performance settings
    load_balancing_mode = "LeastRequests"
    use_32_bit_worker   = false
    worker_count        = 1

    # Health check
    # health_check_eviction_time_in_min = 0

    # Default documents
    default_documents = [
      "Default.htm",
      "Default.html",
      "Default.asp",
      "index.htm",
      "index.html",
      "iisstart.htm",
      "default.aspx",
      "index.php",
      "hostingstart.html"
    ]

    application_stack {
      # Docker configuration (takes precedence if docker_image is specified)
      docker_image_name        = var.docker_image_mcp
      docker_registry_url      = var.docker_registry_url
      docker_registry_username = var.docker_registry_username
      docker_registry_password = var.docker_registry_password
    }
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to these as they may be modified by deployments
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      zip_deploy_file
    ]
  }
}