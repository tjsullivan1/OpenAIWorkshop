# Local Values
# Define computed values and complex expressions

locals {
  # Common naming convention
  name_prefix = "openai-workshop"
  
  # Resource naming
  storage_account_name = "st${replace(lower(local.name_prefix), "-", "")}${random_string.suffix.result}"
  key_vault_name       = "kv-${local.name_prefix}-${random_string.suffix.result}"
  
  # Common tags applied to all resources
  common_tags = merge(var.tags, {
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  })
}

# Random string for unique resource names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}