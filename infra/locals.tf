# Local Values
# Define computed values and complex expressions


locals {
  # Common naming convention
  name_prefix = "${var.project_prefix}-${var.project_stage}"

  # Resource naming
  resource_group_name = "rg-${local.name_prefix}-${random_string.suffix.result}"
  ai_hub_name         = "aihub-${local.name_prefix}-${random_string.suffix.result}"
  ai_project_name     = "aiproject-${local.name_prefix}"
  storage_account_name = "st${replace(lower(local.name_prefix), "-", "")}${random_string.suffix.result}"
  key_vault_name       = "kv-${local.name_prefix}-${random_string.suffix.result}"

  # Common tags applied to all resources
  # CreatedDate is set once and should not change on subsequent runs
  common_tags = merge(var.tags, {
    CreatedDate = var.created_date != null ? var.created_date : formatdate("YYYY-MM-DD", timestamp())
  })
}

# Random string for unique resource names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}