# OpenAI Workshop Infrastructure

This directory contains Terraform configuration files for deploying the Azure infrastructure required for the OpenAI Workshop.

## Architecture

The infrastructure includes:

- **Resource Group**: Container for all workshop resources
- **Azure AI Hub**: Machine Learning workspace for AI project management
- **Azure OpenAI**: Cognitive Services account with GPT model deployment
- **Storage Account**: Blob storage for AI Hub and project data
- **Key Vault**: Secure storage for secrets and keys
- **Application Insights**: Monitoring and telemetry
- **Log Analytics Workspace**: Centralized logging

## Prerequisites

1. **Azure CLI**: Install and authenticate with `az login`
2. **Terraform**: Install Terraform CLI (>= 1.0)
3. **Azure Subscription**: Valid Azure subscription with sufficient permissions
4. **Required Permissions**: 
   - Contributor role on the subscription or resource group
   - User Access Administrator (for RBAC assignments)

## Quick Start

1. **Clone and navigate to the infrastructure directory**:
   ```bash
   git clone <repository-url>
   cd OpenAIWorkshop/infra
   ```

2. **Copy and customize variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your preferred values
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Plan the deployment**:
   ```bash
   terraform plan
   ```

5. **Apply the configuration**:
   ```bash
   terraform apply
   ```

6. **Get outputs**:
   ```bash
   terraform output
   ```

## Configuration

### Required Variables

- `location`: Azure region for deployment (default: "East US")
- `resource_group_name`: Name of the resource group

### Optional Variables

- `ai_hub_name`: Name of the Azure AI Hub
- `openai_deployment_name`: Name for the GPT model deployment
- `openai_model_name`: OpenAI model to deploy (default: "gpt-4o")
- `tags`: Map of tags to apply to all resources

### Example terraform.tfvars

```hcl
location            = "East US"
resource_group_name = "rg-my-openai-workshop"
ai_hub_name         = "aihub-my-workshop"

tags = {
  Environment = "Development"
  Project     = "OpenAI-Workshop"
  Owner       = "john.doe@company.com"
}
```

## Outputs

After successful deployment, Terraform will output:

- **Azure AI Hub**: Name and workspace ID
- **Azure OpenAI**: Endpoint URL and deployment name  
- **Storage Account**: Name and blob endpoint
- **Key Vault**: Name and URI
- **Application Insights**: Connection strings

## Post-Deployment Setup

1. **Configure Environment Variables**: Update your `.env` file with the Terraform outputs:
   ```bash
   # Get outputs in a format suitable for .env
   terraform output -json > outputs.json
   ```

2. **Set up Azure AI Project**: 
   - Navigate to [Azure AI Foundry](https://ai.azure.com)
   - Create a new project in the deployed hub
   - Configure model deployments as needed

3. **Configure Application**: Update application configuration with:
   - Azure OpenAI endpoint
   - Model deployment name
   - Key Vault URI for secrets

## Resource Naming Convention

Resources are named using the following pattern:
- Resource Group: `{resource_group_name}`
- AI Hub: `{ai_hub_name}`
- Storage Account: `st{sanitized_name}{random_suffix}`
- Key Vault: `kv-{name_prefix}-{random_suffix}`
- Other resources: `{type}-{ai_hub_name}`

## Cost Optimization

- **OpenAI Model**: Starts with 10 TPM capacity (adjustable)
- **Storage Account**: Standard LRS tier
- **AI Hub**: Pay-as-you-go pricing
- **Application Insights**: Per-GB ingestion pricing

To minimize costs:
1. Scale down OpenAI deployments when not in use
2. Set up budget alerts in Azure portal
3. Use `terraform destroy` to clean up when finished

## Security Considerations

- **Key Vault**: Configured with current user access policies
- **Storage Account**: Private access by default
- **OpenAI**: No public network restrictions (configure as needed)
- **Managed Identity**: AI Hub uses system-assigned identity

## Troubleshooting

### Common Issues

1. **Authentication Errors**:
   ```bash
   az login
   az account set --subscription <subscription-id>
   ```

2. **Insufficient Permissions**:
   - Ensure Contributor role on subscription/resource group
   - May need User Access Administrator for Key Vault policies

3. **Resource Name Conflicts**:
   - Modify `terraform.tfvars` with unique names
   - Storage accounts and Key Vaults require globally unique names

4. **Quota Limits**:
   - Check Azure OpenAI service availability in your region
   - May need to request quota increases for certain resources

### Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Warning**: This will permanently delete all resources created by Terraform.

## Support

For issues related to:
- **Terraform**: Check [Terraform Azure Provider docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- **Azure AI**: See [Azure AI Hub documentation](https://docs.microsoft.com/azure/machine-learning/)
- **Azure OpenAI**: Reference [Azure OpenAI Service docs](https://docs.microsoft.com/azure/cognitive-services/openai/)