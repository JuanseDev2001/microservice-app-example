# Script PowerShell para configurar Cache-Aside
param([string]$Action = "setup")

function Write-Info { param([string]$msg) Write-Host "[INFO] $msg" -ForegroundColor Green }
function Write-Error-Custom { param([string]$msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }
function Write-Success { param([string]$msg) Write-Host "[SUCCESS] $msg" -ForegroundColor Yellow }

Write-Host "🚀 Configuración Cache-Aside Pattern (Windows)" -ForegroundColor Magenta
Write-Host "===============================================" -ForegroundColor Magenta
Write-Host ""

# Verificar Docker
Write-Info "Verificando Docker..."
try {
    $dockerVersion = docker --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Info "Docker encontrado: $dockerVersion"
    } else {
        Write-Error-Custom "Docker no está disponible"
        exit 1
    }
} catch {
    Write-Error-Custom "Docker no está instalado"
    exit 1
}

# Verificar Docker Compose
Write-Info "Verificando Docker Compose..."
try {
    docker-compose --version | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Info "Docker Compose encontrado ✓"
    } else {
        Write-Error-Custom "Docker Compose no está disponible"
        exit 1
    }
} catch {
    Write-Error-Custom "Docker Compose no está disponible"
    exit 1
}

switch ($Action) {
    "setup" {
        Write-Info "Iniciando configuración completa..."
        
        # Parar servicios existentes
        Write-Info "Parando servicios existentes..."
        docker-compose -f docker-compose.redis.yml down 2>$null | Out-Null
        
        # Iniciar Redis
        Write-Info "Iniciando Redis..."
        docker-compose -f docker-compose.redis.yml up -d
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Redis iniciado correctamente ✓"
            
            # Esperar a que Redis esté listo
            Write-Info "Esperando a que Redis esté listo..."
            Start-Sleep -Seconds 10
            
            # Verificar Redis
            $pingResult = docker exec microservice-redis-cache redis-cli ping 2>$null
            if ($pingResult -eq "PONG") {
                Write-Success "Redis responde correctamente ✓"
                
                # Configurar todos-api
                Write-Info "Configurando todos-api..."
                if (Test-Path "todos-api\package.json") {
                    Push-Location "todos-api"
                    npm install
                    
                    # Crear archivo .env
                    $envContent = @"
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_CHANNEL=log_channel
TODO_API_PORT=8082
JWT_SECRET=your-secret-key
ZIPKIN_URL=http://127.0.0.1:9411/api/v2/spans
"@
                    $envContent | Out-File -FilePath ".env" -Encoding UTF8
                    
                    Pop-Location
                    Write-Success "todos-api configurado ✓"
                } else {
                    Write-Error-Custom "todos-api/package.json no encontrado"
                }
                
                # Mostrar resumen
                Write-Host ""
                Write-Success "=== CONFIGURACIÓN COMPLETADA ==="
                Write-Host "✅ Redis funcionando en puerto 6379" -ForegroundColor Green
                Write-Host "✅ Redis Commander disponible en http://localhost:8081" -ForegroundColor Green
                Write-Host "✅ Cache-Aside implementado en todos-api" -ForegroundColor Green
                Write-Host ""
                Write-Host "🧪 Para probar:" -ForegroundColor Cyan
                Write-Host "   .\scripts\setup-cache.ps1 test" -ForegroundColor White
                Write-Host ""
                Write-Host "📊 Para monitorear Redis:" -ForegroundColor Cyan
                Write-Host "   .\scripts\setup-cache.ps1 monitor" -ForegroundColor White
                
            } else {
                Write-Error-Custom "Redis no responde después de iniciarse"
            }
        } else {
            Write-Error-Custom "Error iniciando Redis"
        }
    }
    
    "test" {
        Write-Info "Ejecutando tests básicos..."
        
        # Test Redis
        $pingResult = docker exec microservice-redis-cache redis-cli ping 2>$null
        if ($pingResult -eq "PONG") {
            Write-Success "✓ Redis funcionando"
            
            # Limpiar cache
            Write-Info "Limpiando cache..."
            docker exec microservice-redis-cache redis-cli FLUSHALL | Out-Null
            Write-Info "Cache limpiado"
            
            # Simular operaciones cache
            Write-Info "Simulando Cache-Aside..."
            docker exec microservice-redis-cache redis-cli SET "test:cache:demo" "Demo data" EX 60 | Out-Null
            
            $result = docker exec microservice-redis-cache redis-cli GET "test:cache:demo" 2>$null
            if ($result -eq "Demo data") {
                Write-Success "✓ Cache funcionando correctamente"
            }
            
            # Mostrar estadísticas
            $keyCount = docker exec microservice-redis-cache redis-cli DBSIZE 2>$null
            Write-Info "Keys en cache: $keyCount"
            
            # Demo completo
            Write-Host ""
            Write-Success "=== DEMO CACHE-ASIDE ==="
            
            # Simular datos de usuario
            $userData = '{"items":[{"id":1,"content":"Task 1"},{"id":2,"content":"Task 2"}]}'
            docker exec microservice-redis-cache redis-cli SET "todos:user123:list" $userData EX 300 | Out-Null
            Write-Host "✓ Cache MISS simulado - Datos guardados en cache" -ForegroundColor Yellow
            
            # Simular cache hit
            $cachedData = docker exec microservice-redis-cache redis-cli GET "todos:user123:list" 2>$null
            Write-Host "✓ Cache HIT - Datos obtenidos del cache: $($cachedData.Substring(0, 50))..." -ForegroundColor Green
            
            # Simular invalidación
            docker exec microservice-redis-cache redis-cli DEL "todos:user123:list" | Out-Null
            Write-Host "✓ Cache invalidado después de modificación" -ForegroundColor Red
            
        } else {
            Write-Error-Custom "✗ Redis no está funcionando"
        }
    }
    
    "cleanup" {
        Write-Info "Limpiando recursos..."
        docker-compose -f docker-compose.redis.yml down
        Write-Success "Recursos limpiados ✓"
    }
    
    "monitor" {
        Write-Info "Iniciando monitor de Redis (Ctrl+C para salir)..."
        docker exec -it microservice-redis-cache redis-cli monitor
    }
    
    "demo" {
        Write-Success "=== DEMO INTERACTIVO CACHE-ASIDE ==="
        Write-Host ""
        
        # Verificar Redis
        $pingResult = docker exec microservice-redis-cache redis-cli ping 2>$null
        if ($pingResult -ne "PONG") {
            Write-Error-Custom "Redis no está funcionando. Ejecuta primero: .\scripts\setup-cache.ps1 setup"
            return
        }
        
        # Limpiar cache
        docker exec microservice-redis-cache redis-cli FLUSHALL | Out-Null
        Write-Host "1. Cache limpiado - Estado inicial" -ForegroundColor Cyan
        
        # Mostrar cache vacío
        $keyCount = docker exec microservice-redis-cache redis-cli DBSIZE 2>$null
        Write-Host "   Keys en cache: $keyCount" -ForegroundColor Gray
        
        Write-Host ""
        Write-Host "2. Simulando primera consulta (Cache MISS)..." -ForegroundColor Yellow
        $userData = '{"items":[{"id":1,"content":"Buy groceries"},{"id":2,"content":"Walk dog"}]}'
        docker exec microservice-redis-cache redis-cli SET "todos:alice:list" $userData EX 600 | Out-Null
        Write-Host "   → Consulta a DB (lenta ~200ms)" -ForegroundColor Red
        Write-Host "   → Datos guardados en cache" -ForegroundColor Yellow
        
        # Mostrar estado del cache
        $keyCount = docker exec microservice-redis-cache redis-cli DBSIZE 2>$null
        Write-Host "   Keys en cache: $keyCount" -ForegroundColor Gray
        
        Write-Host ""
        Write-Host "3. Simulando segunda consulta (Cache HIT)..." -ForegroundColor Green
        $cachedData = docker exec microservice-redis-cache redis-cli GET "todos:alice:list" 2>$null
        Write-Host "   → Datos del cache (rápido ~20ms)" -ForegroundColor Green
        Write-Host "   → Datos: $($cachedData.Substring(0, 40))..." -ForegroundColor Gray
        
        Write-Host ""
        Write-Host "4. Simulando creación de nuevo todo (Invalidación)..." -ForegroundColor Red
        docker exec microservice-redis-cache redis-cli DEL "todos:alice:list" | Out-Null
        Write-Host "   → Cache invalidado" -ForegroundColor Red
        Write-Host "   → Próxima consulta será Cache MISS" -ForegroundColor Yellow
        
        # Verificar cache vacío
        $keyCount = docker exec microservice-redis-cache redis-cli DBSIZE 2>$null
        Write-Host "   Keys en cache: $keyCount" -ForegroundColor Gray
        
        Write-Host ""
        Write-Success "✨ Demo completado. Patrón Cache-Aside demostrado!"
        Write-Host "🌐 Ver Redis Commander: http://localhost:8081" -ForegroundColor Cyan
    }
    
    default {
        Write-Host "Uso: .\scripts\setup-cache.ps1 [setup|test|cleanup|monitor|demo]"
        Write-Host ""
        Write-Host "  setup    - Configurar todo el entorno"
        Write-Host "  test     - Ejecutar tests básicos"
        Write-Host "  demo     - Demo interactivo del patrón"
        Write-Host "  cleanup  - Limpiar recursos"
        Write-Host "  monitor  - Monitor Redis en tiempo real"
    }
}