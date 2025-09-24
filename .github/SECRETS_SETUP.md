# GitHub Secrets Configuration Guide

## Required Secrets for CI/CD Pipeline

### Azure Authentication Secrets

1. **AZURE_CREDENTIALS** - Azure Service Principal JSON
   ```json
   {
     "clientId": "your-client-id",
     "clientSecret": "your-client-secret",
     "subscriptionId": "your-subscription-id",
     "tenantId": "your-tenant-id"
   }
   ```

2. **ARM_CLIENT_ID** - Azure Service Principal Client ID
3. **ARM_CLIENT_SECRET** - Azure Service Principal Client Secret  
4. **ARM_SUBSCRIPTION_ID** - Your Azure Subscription ID
5. **ARM_TENANT_ID** - Your Azure Tenant ID

### SSH Access Secrets

6. **SSH_PRIVATE_KEY** - Private SSH key for VM access (contents of ~/.ssh/microapp_rsa)
7. **VM_IP** - Fallback VM IP address (optional)

## How to Configure Secrets

### Step 1: Create Azure Service Principal
```bash
# Create service principal for GitHub Actions
az ad sp create-for-rbac --name "github-actions-microapp" \
  --role contributor \
  --scopes /subscriptions/YOUR_SUBSCRIPTION_ID \
  --sdk-auth
```

### Step 2: Add Secrets to GitHub Repository
1. Go to your repository on GitHub
2. Navigate to Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add each secret with the corresponding value

### Step 3: Create Environments (Optional but recommended)
1. Go to Settings → Environments
2. Create environments: "staging" and "production"
3. Add environment-specific secrets and protection rules

## Environment Variables (Repository Variables)

These can be set as repository or environment variables:

- **TF_VERSION**: "1.5.0"
- **VM_SIZE**: "Standard_B2s" 
- **REGION**: "East US"

## Protection Rules (Recommended)

### For Production Environment:
- Require reviewers before deployment
- Restrict which branches can deploy to production
- Add deployment protection rules

### Branch Protection:
- Require pull request reviews for main branch
- Require status checks to pass before merging
- Require branches to be up to date before merging