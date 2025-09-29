# Configuración de Branch Protection

## Branch Protection Rules

Para configurar las reglas de protección de branches en GitHub:

### 1. Main Branch Protection

**Branch:** `main`

```yaml
Settings -> Branches -> Add rule

Branch name pattern: main

Configuración recomendada:
   Require pull request reviews before merging
  - Required approving reviews: 1
  - Dismiss stale PR approvals when new commits are pushed
   Require status checks to pass before merging
  - Require branches to be up to date before merging
  - Status checks required:
    - CI/CD Pipeline / test
    - CI/CD Pipeline / build
    - CI/CD Pipeline / docker
   Require branches to be up to date before merging
   Include administrators
   Allow force pushes: false
   Allow deletions: false
```

### 2. Staging Environment Branch Protection

**Branch:** `env/staging`

```yaml
Settings -> Branches -> Add rule

Branch name pattern: env/staging

Configuración recomendada:
   Require pull request reviews before merging
  - Required approving reviews: 1
   Require status checks to pass before merging
  - Status checks required:
    - Infrastructure Pipeline - Staging / validate
    - Infrastructure Pipeline - Staging / plan
   Restrict pushes that create files
   Include administrators
   Allow force pushes: false
   Allow deletions: false
```

### 3. Production Environment Branch Protection

**Branch:** `env/production`

```yaml
Settings -> Branches -> Add rule

Branch name pattern: env/production

Configuración recomendada:
   Require pull request reviews before merging
  - Required approving reviews: 2 (mínimo)
  - Require review from CODEOWNERS
   Require status checks to pass before merging
  - Status checks required:
    - Infrastructure Pipeline - Production / validate
    - Infrastructure Pipeline - Production / plan
   Restrict pushes that create files
    Require signed commits
    Include administrators
    Allow force pushes: false
    Allow deletions: false
```

## Environment Protection Rules

### Staging Environment
```yaml
Environment name: staging-infrastructure
Protection rules:
- Required reviewers: 1 person from DevOps team
- Wait timer: 0 minutes
- Deployment branches: env/staging only
```

### Production Environment
```yaml
Environment name: production-infrastructure
Protection rules:
- Required reviewers: 2 people (including 1 DevOps lead)
- Wait timer: 10 minutes
- Deployment branches: env/production only
- Prevent self-review: true
```

## Comandos para configurar vía GitHub CLI

```bash
# Instalar GitHub CLI si no está instalado
# https://cli.github.com/

# Configurar branch protection para main
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"checks":[{"context":"CI/CD Pipeline / test"},{"context":"CI/CD Pipeline / build"}]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true}' \
  --field restrictions=null

# Configurar branch protection para env/staging
gh api repos/:owner/:repo/branches/env/staging/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"checks":[{"context":"Infrastructure Pipeline - Staging / validate"}]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field restrictions=null

# Configurar branch protection para env/production
gh api repos/:owner/:repo/branches/env/production/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"checks":[{"context":"Infrastructure Pipeline - Production / validate"}]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":2}' \
  --field restrictions=null
```

## Workflow de Branches

```
main (desarrollo)
├── feature/cache-implementation
├── feature/new-auth-feature
└── bugfix/users-api-fix

env/staging (staging deployment)
├── Recibe merges desde main
└── Trigger: Infrastructure Pipeline - Staging

env/production (production deployment)
├── Recibe merges desde env/staging (después de validación)
└── Trigger: Infrastructure Pipeline - Production
```

## Scripts de Automatización

### Crear branches de entorno
```bash
#!/bin/bash
# create-environment-branches.sh

echo "Creando branches de entorno..."

# Crear branch de staging
git checkout -b env/staging
git push -u origin env/staging

# Crear branch de production
git checkout -b env/production
git push -u origin env/production

# Volver a main
git checkout main

echo "Branches de entorno creados"
```

### Sincronizar entornos
```bash
#!/bin/bash
# sync-environments.sh

echo "Sincronizando entornos..."

# Sincronizar staging con main
git checkout env/staging
git merge main
git push origin env/staging

echo "Staging sincronizado"
echo "Para production, usar Pull Request manual"
```