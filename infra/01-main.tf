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
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  })

  tags = var.tags

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
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  })

  tags = var.tags

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