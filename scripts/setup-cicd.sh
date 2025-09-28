#!/bin/bash

# Azure CI/CD Setup Script
# This script helps configure Azure Service Principal and GitHub Secrets

set -e

echo "Setting up CI/CD for Microservices Application"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}ERROR: Azure CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if user is logged in to Azure
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}WARNING: Not logged in to Azure. Please login first.${NC}"
    az login
fi

# Get current subscription
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)

echo -e "${GREEN}SUCCESS: Current subscription: $SUBSCRIPTION_ID${NC}"

# Create Service Principal
echo -e "${YELLOW}INFO: Creating Service Principal for GitHub Actions...${NC}"

SP_NAME="github-actions-microapp-$(date +%s)"
SP_JSON=$(az ad sp create-for-rbac --name "$SP_NAME" \
  --role contributor \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" \
  --sdk-auth)

CLIENT_ID=$(echo $SP_JSON | jq -r '.clientId')
CLIENT_SECRET=$(echo $SP_JSON | jq -r '.clientSecret')

echo -e "${GREEN}SUCCESS: Service Principal created successfully!${NC}"

# Display secrets to be added to GitHub
echo -e "\n${YELLOW}INFO: GitHub Secrets Configuration${NC}"
echo "=================================="
echo "Add these secrets to your GitHub repository:"
echo ""
echo "1. AZURE_CREDENTIALS:"
echo "$SP_JSON"
echo ""
echo "2. ARM_CLIENT_ID:"
echo "$CLIENT_ID"
echo ""
echo "3. ARM_CLIENT_SECRET:"
echo "$CLIENT_SECRET"
echo ""
echo "4. ARM_SUBSCRIPTION_ID:"
echo "$SUBSCRIPTION_ID"
echo ""
echo "5. ARM_TENANT_ID:"
echo "$TENANT_ID"
echo ""

# Check if SSH key exists
if [ -f ~/.ssh/microapp_rsa ]; then
    echo "6. SSH_PRIVATE_KEY:"
    echo "Copy the contents of ~/.ssh/microapp_rsa"
    echo ""
else
    echo -e "${YELLOW}WARNING: SSH key not found. Please generate one first.${NC}"
fi

echo -e "${GREEN}SUCCESS: Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Add the above secrets to your GitHub repository"
echo "2. Push your code to trigger the pipeline"
echo "3. Monitor the Actions tab in your GitHub repository"
echo ""
echo "For more details, see .github/SECRETS_SETUP.md"