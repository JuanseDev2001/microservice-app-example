# 🏗️ Configuración de Infraestructura - Staging Environment

Esta configuración está optimizada para el entorno de **staging**.

## ⚙️ Configuración específica de Staging

- **Recursos**: Configuración media para testing
- **Logs**: Nivel DEBUG habilitado
- **Monitoring**: Métricas detalladas activadas
- **Health Checks**: Cada 15 segundos
- **Auto-restart**: Habilitado con reintentos

## 🔧 Variables de entorno - Staging

```bash
ENVIRONMENT=staging
LOG_LEVEL=DEBUG
CACHE_TTL=300  # 5 minutos para testing
HEALTH_CHECK_INTERVAL=15
MAX_RETRIES=3
```

## 📊 Monitoreo de Staging

- Dashboard: http://localhost:3000/staging
- Logs: Agregados en ELK stack
- Alertas: Slack #staging-alerts

---

*Cambio realizado para demostrar pipeline GitOps de staging* 🎬

**Última actualización**: $(date)
**Versión**: v1.2-staging
**Pipeline**: infrastructure-staging.yml