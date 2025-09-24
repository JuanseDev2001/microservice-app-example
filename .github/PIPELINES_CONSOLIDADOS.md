# Pipelines Consolidados - Guía de Uso

Los pipelines han sido **consolidados y mejorados** para trabajar con **Azure VMs** usando Terraform para infraestructura y despliegue remoto.

## **Estructura de Pipelines:**

### 1. **`ci-cd.yml`** - Pipeline Principal
- **Tests** automáticos (Java, Node.js, Go)
- **Build** de aplicaciones 
- **Docker** image building
- **Deploy** a VM staging/production
- **Integration tests** remotos

### 2. **`infrastructure-staging.yml`** - Infraestructura Staging
- **Terraform** para crear VM de staging
- **Validación** de configuración
- **Deploy** automático de infraestructura

### 3. **`infrastructure-production.yml`** - Infraestructura Production
- **Terraform** para crear VM de producción
- **Protecciones** adicionales de producción
- **Approval** requerido para deployment

## **Flujos de Trabajo:**

### **Desarrollo Normal (Feature → Staging):**
```bash
# 1. Desarrollo en feature branch
git checkout -b feature/nueva-funcionalidad
# ... hacer cambios ...
git push origin feature/nueva-funcionalidad

# 2. PR a develop
# Esto ejecuta: tests + build + docker validation

# 3. Merge a develop
# Esto ejecuta: deploy automático a staging VM
```

### **Release a Producción (Staging → Production):**
```bash
# 1. PR de develop a main  
# Esto ejecuta: tests + build + validaciones

# 2. Merge a main
# Esto ejecuta: deploy automático a production VM (con approval)
```

### **Deploy de Infraestructura:**
```bash
# Staging
git checkout env/staging
# ... hacer cambios en infra/terraform ...
git push origin env/staging
# Ejecuta: terraform apply en staging

# Production  
git checkout env/production
# ... hacer cambios en infra/terraform ...
git push origin env/production  
# Ejecuta: terraform apply en production (con approval)
```

## **Secrets Requeridos:**

### **Azure Authentication:**
- `AZURE_CREDENTIALS` - Service Principal JSON
- `ARM_CLIENT_ID` - Azure Client ID
- `ARM_CLIENT_SECRET` - Azure Client Secret  
- `ARM_SUBSCRIPTION_ID` - Azure Subscription ID
- `ARM_TENANT_ID` - Azure Tenant ID

### **VM Access:**
- `SSH_PRIVATE_KEY` - SSH private key para conectar a VMs
- `VM_IP_STAGING` - IP de VM staging (opcional, se obtiene de Terraform)
- `VM_IP_PRODUCTION` - IP de VM production (opcional, se obtiene de Terraform)

## **Environments en GitHub:**

### **Staging:**
- Sin protecciones
- Deploy automático en develop

### **Production:** 
- **Requiere approval** 
- Solo desde main branch
- Deploy automático después de approval

### **Staging-Infrastructure / Production-Infrastructure:**
- Para cambios de infraestructura
- Protecciones adicionales en production

## **Monitoring:**

### **Durante Deploy:**
- Logs en tiempo real en GitHub Actions
- Health checks automáticos
- Rollback automático en caso de fallo

### **Post Deploy:**
- URLs de servicios en logs
- Status de contenedores
- Verification tests

## **Troubleshooting:**

### **Fallo en Tests:**
```bash
# Ejecutar tests localmente
cd users-api && mvn test
cd frontend && npm test  
cd auth-api && go test
```

### **Fallo en Deploy:**
```bash
# Conectar a VM manualmente
ssh azureuser@<vm-ip>
docker-compose ps
docker-compose logs <service>
```

### **Fallo en Infraestructura:**
```bash
# Revisar Terraform localmente
cd infra/terraform
terraform plan -var-file="staging.tfvars"
```

## **Ventajas de esta Consolidación:**

- **Mantiene** la estructura de testing existente
- **Mejora** con deployment real a VMs
- **Elimina** redundancia de pipelines  
- **Conserva** las protecciones de producción
- **Añade** gestión de infraestructura con Terraform
- **Simplifica** la configuración (menos archivos)

## **Next Steps:**

1. **Configurar secrets** en GitHub
2. **Actualizar SSH keys** en production.tfvars
3. **Test pipeline** con un pequeño cambio
4. **Monitor deployment** en GitHub Actions

---

**¡Pipelines listos para usar!** Solo necesitas configurar los secrets y hacer push.