# 🚀 Cache-Aside Pattern Implementation

## 📖 Quick Start

Este README te guía paso a paso para implementar y probar el patrón **Cache-Aside** en el proyecto de microservicios.

### ⚡ Setup Rápido

```bash
# 1. Clonar y navegar al proyecto
cd microservice-app-example

# 2. Configurar Cache-Aside automáticamente
chmod +x scripts/setup-cache-aside.sh
./scripts/setup-cache-aside.sh setup

# 3. Ejecutar pruebas
chmod +x scripts/test-cache-aside.sh  
./scripts/test-cache-aside.sh all
```

### 🎯 ¿Qué verás?

1. **Redis Cache** funcionando en Docker
2. **Cache MISS** en primera consulta (más lento)
3. **Cache HIT** en consultas siguientes (más rápido) 
4. **Invalidación** automática al modificar datos
5. **Métricas** de performance en tiempo real

## 🏗️ Arquitectura Implementada

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Client    │────▶│ Todos-API    │────▶│   Redis     │
│             │     │ (Node.js)    │     │   Cache     │
└─────────────┘     └──────────────┘     └─────────────┘
                           │                     ▲
┌─────────────┐            │                     │
│   Client    │────▶┌──────▼──────┐              │
│             │     │ Users-API   │──────────────┘
└─────────────┘     │ (Java)      │
                    └─────────────┘
                           │
                    ┌──────▼──────┐
                    │ PostgreSQL  │
                    │ Database    │
                    └─────────────┘
```

## 📋 Archivos Creados/Modificados

### ✅ Configuración
- `docker-compose.redis.yml` - Redis + Redis Commander
- `scripts/setup-cache-aside.sh` - Script de configuración
- `scripts/test-cache-aside.sh` - Script de testing

### ✅ Todos-API (Node.js)
- `todos-api/cacheAsideService.js` - Servicio Cache-Aside
- `todos-api/todoController.js` - Integración con cache
- `todos-api/server.js` - Configuración Redis v4+
- `todos-api/package.json` - Dependencia Redis actualizada

### ✅ Users-API (Java)  
- `users-api/src/main/java/com/elgris/usersapi/service/CacheAsideService.java`
- `users-api/src/main/java/com/elgris/usersapi/configuration/RedisConfiguration.java`
- `users-api/src/main/java/com/elgris/usersapi/api/UsersController.java` (preparado)
- `users-api/pom.xml` - Dependencia Spring Data Redis

### ✅ Documentación
- `docs/CACHE_ASIDE_IMPLEMENTATION.md` - Documentación detallada

## 🧪 Testing del Patrón

### Test Básico
```bash
# Ver cache en tiempo real
./scripts/test-cache-aside.sh monitor

# En otra terminal, hacer consultas
curl http://localhost:8082/todos
```

### Benchmark Performance
```bash
# Benchmark con 20 iteraciones
./scripts/test-cache-aside.sh benchmark 20
```

### Tests Específicos
```bash
# Ver estadísticas Redis
./scripts/test-cache-aside.sh stats

# Limpiar cache
./scripts/test-cache-aside.sh clear
```

## 📊 Resultados Esperados

### Performance Improvement
- **Cache HIT**: ~10-50ms respuesta
- **Cache MISS**: ~100-300ms respuesta  
- **Mejora típica**: 60-80% más rápido

### Observaciones en Logs
```
[Cache-Aside] Cache MISS for key: todos:username:list
[Cache-Aside] Data cached for key: todos:username:list with TTL: 600s
[Cache-Aside] Cache HIT for key: todos:username:list
[Cache-Aside] Cache invalidated for key: todos:username:list
```

## 🛠️ Herramientas de Monitoreo

### Redis Commander (Web UI)
```bash
# Acceder en el navegador
open http://localhost:8081
```

### Redis CLI Monitor
```bash
# Ver todas las operaciones Redis en tiempo real
docker exec -it microservice-redis-cache redis-cli monitor
```

### Métricas de Redis
```bash
# Ver estadísticas completas
docker exec microservice-redis-cache redis-cli INFO stats
```

## 🐛 Troubleshooting

### Problema: Redis no inicia
```bash
# Verificar Docker
docker ps | grep redis

# Reiniciar Redis
docker-compose -f docker-compose.redis.yml restart redis
```

### Problema: No se ve cache
```bash
# Verificar conexión
docker exec microservice-redis-cache redis-cli ping

# Ver keys existentes  
docker exec microservice-redis-cache redis-cli KEYS "*"
```

### Problema: Cache no se invalida
```bash
# Limpiar manualmente
docker exec microservice-redis-cache redis-cli FLUSHALL

# Verificar logs de aplicación
# Debe aparecer: "[Cache-Aside] Cache invalidated..."
```

## 📚 Flujo de Demostración (8 minutos)

### Minuto 1-2: Setup
1. Mostrar arquitectura en slides
2. Ejecutar `./scripts/setup-cache-aside.sh setup`
3. Abrir Redis Commander

### Minuto 3-4: Cache Miss → Hit
1. Limpiar cache: `redis-cli FLUSHALL`
2. Primera consulta (MISS): `curl todos-api`
3. Segunda consulta (HIT): `curl todos-api`
4. Mostrar diferencia de tiempo

### Minuto 5-6: Invalidación
1. Crear nuevo todo: `POST /todos`
2. Mostrar que cache se invalidó
3. Próxima consulta es MISS

### Minuto 7-8: Métricas
1. Ejecutar benchmark: `./scripts/test-cache-aside.sh benchmark 10`
2. Mostrar estadísticas Redis
3. Q&A y conclusiones

## 🎯 Puntos Clave para la Presentación

1. **Patrón Cache-Aside** = aplicación controla el cache
2. **Performance**: 60-80% mejora en consultas frecuentes
3. **Escalabilidad**: Menos carga en base de datos
4. **Flexibilidad**: TTL configurables, invalidación inteligente
5. **Implementación real** en dos tecnologías (Node.js + Java)

## 📖 Referencias Rápidas

- [Documentación completa](docs/CACHE_ASIDE_IMPLEMENTATION.md)
- [Redis Cache-Aside Pattern](https://redis.io/docs/manual/patterns/cache-aside/)
- [Setup script](scripts/setup-cache-aside.sh)
- [Test script](scripts/test-cache-aside.sh)