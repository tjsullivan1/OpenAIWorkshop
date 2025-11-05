#!/bin/bash

# OpenAI Workshop Infrastructure Cleanup Script
# This script safely destroys the Azure infrastructure created by Terraform

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() {
    echo -e "\n${BLUE}======================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}======================================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

cd "$(dirname "$0")"

print_step "OpenAI Workshop Infrastructure Cleanup"

# Check if Terraform state exists
if [ ! -f "terraform.tfstate" ]; then
    print_error "No Terraform state found. Nothing to destroy."
    exit 1
fi

# Show what will be destroyed
print_step "Resources to be destroyed:"
terraform plan -destroy

print_step "DANGER: This will permanently delete all resources!"
print_warning "This action cannot be undone"
print_warning "All data in storage accounts and other resources will be lost"

echo -e "\nAre you sure you want to proceed? (type 'yes' to confirm)"
read -r confirmation

if [ "$confirmation" != "yes" ]; then
    print_error "Cleanup cancelled"
    exit 1
fi

print_step "Destroying infrastructure..."
terraform destroy -auto-approve

print_success "Infrastructure destroyed successfully"
print_warning "Don't forget to remove any manually created resources or configurations"