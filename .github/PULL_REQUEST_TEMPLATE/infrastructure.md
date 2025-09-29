---
name: Cambio de Infraestructura
about: Pull request para cambios en infraestructura y configuración
title: '[INFRA] '
labels: ['infrastructure', 'ops', 'needs-review']
assignees: ''

---

## Descripción de cambios de infraestructura
<!-- Describe detalladamente los cambios de infraestructura -->

## Entorno objetivo
<!-- Marca el entorno donde se aplicarán los cambios -->
- [ ] Dev
- [ ] Staging (env/staging)
- [ ] Production (env/production)

## 🔧 Tipo de cambio de infraestructura
<!-- Marca con una X el tipo de cambio -->
- [ ] Docker Compose configuration
- [ ] Network configuration
- [ ] Database configuration
- [ ] Redis/Cache configuration
- [ ] Monitoring and logging
- [ ] Security policies
- [ ] Environment variables

## Impacto y riesgos
<!-- Describe el impacto potencial de los cambios -->
- **Downtime estimado**: <!-- ej. 0 minutos, 2-5 minutos, etc. -->
- **Servicios afectados**: <!-- lista de microservicios afectados -->
- **Riesgo**: <!-- Bajo/Medio/Alto -->
- **Rollback plan**: <!-- Describe cómo revertir si algo sale mal -->

## Plan de testing de infraestructura
<!-- Describe cómo has probado los cambios -->
- [ ] Validación local con docker-compose config
- [ ] Probado en entorno local
- [ ] Scripts de deployment validados
- [ ] Health checks funcionando
- [ ] Verificado conectividad entre servicios
- [ ] Cache y base de datos funcionando

## Plan de deployment
<!-- Describe el plan paso a paso -->
1. <!-- Paso 1 -->
2. <!-- Paso 2 -->
3. <!-- Paso 3 -->

## Lista de verificación de infraestructura
<!-- Marca con una X cuando esté completado -->
- [ ] He probado los cambios en mi entorno local
- [ ] Los servicios inician correctamente con los nuevos cambios
- [ ] He verificado que no hay conflictos de configuración
- [ ] He documentado cualquier nueva variable de entorno
- [ ] He considerado el impacto en la seguridad
- [ ] He verificado que el pipeline de CI/CD funciona
- [ ] Tengo un plan de rollback si algo falla

## Monitoreo y verificación
<!-- Describe qué monitorear después del deployment -->
- [ ] Logs de aplicación
- [ ] Métricas de performance
- [ ] Health checks de servicios
- [ ] Estado de la base de datos
- [ ] Funcionamiento del cache
- [ ] Conectividad entre microservicios

## Comandos para testing manual
```bash
# Comandos para probar los cambios localmente
docker-compose config                    # Validar configuración
docker-compose up -d                     # Levantar servicios
docker-compose ps                        # Verificar estado
curl http://localhost:9081/users/cache/stats  # Test API
```
