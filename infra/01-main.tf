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


