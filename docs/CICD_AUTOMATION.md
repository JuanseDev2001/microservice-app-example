# CI/CD Pipeline Automation

Este proyecto incluye pipelines de CI/CD completamente automatizados usando GitHub Actions para desplegar la aplicación de microservicios en Azure.

## Características del Pipeline

### Pipeline de Infraestructura (`infrastructure.yml`)
- **Terraform** para Infrastructure as Code
- Despliegue automático de VM en Azure
- Soporte para múltiples entornos (staging/production)
- Validación y formateo de código Terraform
- Almacenamiento de estado remoto

### Pipeline de Aplicación (`deploy.yml`)
- Build automático de imágenes Docker
- Tests de integración
- Despliegue con Docker Compose
- Smoke tests post-despliegue
- Rollback automático en caso de fallo

### Pipeline Completo (`full-pipeline.yml`)
- Orquestación de infraestructura y aplicación
- Despliegue end-to-end automatizado
- Soporte para despliegues manuales

## 🛠️ Configuración Inicial

### 1. Ejecutar Script de Configuración
```bash
# Hacer ejecutable el script
chmod +x scripts/setup-cicd.sh

# Ejecutar configuración
./scripts/setup-cicd.sh
```

### 2. Configurar Secrets en GitHub
1. Ve a tu repositorio en GitHub
2. Settings → Secrets and variables → Actions
3. Agrega los secrets mostrados por el script

### 3. Configurar Entornos (Opcional)
1. Settings → Environments
2. Crea entornos: `staging` y `production`
3. Configura reglas de protección

## Usar los Pipelines

### Despliegue Automático
```bash
# Push a main/master triggers automatic deployment
git push origin main
```

### Despliegue Manual
1. Ve a Actions en GitHub
2. Selecciona "Complete CI/CD Pipeline"
3. Click "Run workflow"
4. Selecciona entorno y opciones

### Solo Infraestructura
1. Actions → "Infrastructure Deployment"
2. Selecciona acción: plan/apply/destroy

### Solo Aplicación
1. Actions → "Application Deployment"
2. Especifica VM IP si es necesario

## Entornos

### Staging
- **Branch**: `env/staging`
- **VM**: Automáticamente desplegada
- **URL**: `http://<vm-ip>:9083`

### Production
- **Branch**: `main`
- **Protección**: Requiere aprobación
- **URL**: `http://<vm-ip>:9083`

## Monitoreo

### Logs de Despliegue
- GitHub Actions proporciona logs detallados
- Cada step muestra output en tiempo real
- Artifacts guardados para debugging

### Health Checks
- Verificación automática de servicios
- Tests de conectividad Redis
- Validación de endpoints HTTP

## Troubleshooting

### Fallo en Terraform
```bash
# Revisar plan localmente
terraform plan -var-file="staging.tfvars"

# Importar estado si es necesario
terraform import azurerm_resource_group.main /subscriptions/.../resourceGroups/...
```

### Fallo en Docker
```bash
# Conectar a VM y verificar
ssh azureuser@<vm-ip>
docker compose ps
docker compose logs
```

### Secrets Incorrectos
1. Verificar formato de AZURE_CREDENTIALS
2. Validar permisos del Service Principal
3. Comprobar SSH key format

## Workflow Triggers

### Automáticos
- **Push a main**: Despliegue completo a staging
- **PR a main**: Solo validación y tests
- **Push a infra/**: Solo infraestructura

### Manuales
- **workflow_dispatch**: Permite control completo
- **Selección de entorno**: staging/production
- **Acciones específicas**: plan/apply/destroy

## Mejoras Futuras

- [ ] Integration con Azure DevOps
- [ ] Monitoring con Application Insights
- [ ] Blue-Green Deployments
- [ ] Canary Releases
- [ ] Auto-scaling basado en métricas
- [ ] Backup automático de base de datos

## Seguridad

- Service Principal con permisos mínimos
- Secrets encriptados en GitHub
- SSH keys rotan periódicamente
- Network Security Groups configurados
- HTTPS termination con Load Balancer