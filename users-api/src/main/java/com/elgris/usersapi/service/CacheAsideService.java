package com.elgris.usersapi.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.Set;
import java.util.concurrent.TimeUnit;
import java.util.function.Supplier;

/**
 * Implementación del patrón Cache-Aside usando Spring Data Redis
 * 
 * Este servicio implementa el patrón Cache-Aside donde:
 * 1. La aplicación primero verifica si los datos están en cache
 * 2. Si no están (cache miss), consulta la fuente de datos original
 * 3. Guarda los datos en cache para futuras consultas
 * 4. Retorna los datos al cliente
 */
@Service
public class CacheAsideService {
    
    private static final Logger logger = LoggerFactory.getLogger(CacheAsideService.class);
    
    @Autowired
    private RedisTemplate<String, String> redisTemplate;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    private final int DEFAULT_TTL_SECONDS = 600; // 10 minutos
    
    /**
     * Implementación del patrón Cache-Aside
     * @param cacheKey Clave única para el cache
     * @param dataFetcher Función que obtiene los datos de la fuente original
     * @param clazz Clase del objeto a deserializar
     * @param ttlSeconds Tiempo de vida en segundos
     * @return Los datos solicitados
     */
    public <T> T getWithCacheAside(String cacheKey, Supplier<T> dataFetcher, Class<T> clazz, int ttlSeconds) {
        try {
            // Paso 1: Verificar si los datos están en cache
            logger.debug("[Cache-Aside] Checking cache for key: {}", cacheKey);
            String cachedData = redisTemplate.opsForValue().get(cacheKey);
            
            if (cachedData != null && !cachedData.isEmpty()) {
                // Cache hit - retornar datos del cache
                logger.debug("[Cache-Aside] Cache HIT for key: {}", cacheKey);
                return deserializeData(cachedData, clazz);
            }
            
            // Paso 2: Cache miss - obtener datos de la fuente original
            logger.debug("[Cache-Aside] Cache MISS for key: {}, fetching from source", cacheKey);
            T freshData = dataFetcher.get();
            
            // Paso 3: Guardar en cache para futuras consultas
            if (freshData != null) {
                String serializedData = serializeData(freshData);
                redisTemplate.opsForValue().set(cacheKey, serializedData, ttlSeconds, TimeUnit.SECONDS);
                logger.debug("[Cache-Aside] Data cached for key: {} with TTL: {}s", cacheKey, ttlSeconds);
            }
            
            // Paso 4: Retornar datos al cliente
            return freshData;
            
        } catch (Exception error) {
            logger.error("[Cache-Aside] Error for key {}: {}", cacheKey, error.getMessage(), error);
            // Si hay error con cache, intentar obtener directamente de la fuente
            try {
                return dataFetcher.get();
            } catch (Exception fetchError) {
                logger.error("[Cache-Aside] Error fetching from source: {}", fetchError.getMessage(), fetchError);
                throw new RuntimeException("Error fetching data", fetchError);
            }
        }
    }
    
    /**
     * Sobrecarga con TTL por defecto
     */
    public <T> T getWithCacheAside(String cacheKey, Supplier<T> dataFetcher, Class<T> clazz) {
        return getWithCacheAside(cacheKey, dataFetcher, clazz, DEFAULT_TTL_SECONDS);
    }
    
    /**
     * Invalidar cache (útil para operaciones de escritura)
     * @param cacheKey Clave a invalidar
     */
    public void invalidateCache(String cacheKey) {
        try {
            redisTemplate.delete(cacheKey);
            logger.debug("[Cache-Aside] Cache invalidated for key: {}", cacheKey);
        } catch (Exception error) {
            logger.error("[Cache-Aside] Error invalidating cache for key {}: {}", cacheKey, error.getMessage(), error);
        }
    }
    
    /**
     * Invalidar múltiples claves de cache usando un patrón
     * @param pattern Patrón de claves a invalidar (ej: "user:*")
     */
    public void invalidateCachePattern(String pattern) {
        try {
            Set<String> keys = redisTemplate.keys(pattern);
            if (keys != null && !keys.isEmpty()) {
                redisTemplate.delete(keys);
                logger.debug("[Cache-Aside] Invalidated {} cache keys matching pattern: {}", keys.size(), pattern);
            }
        } catch (Exception error) {
            logger.error("[Cache-Aside] Error invalidating cache pattern {}: {}", pattern, error.getMessage(), error);
        }
    }
    
    /**
     * Generar clave de cache estandarizada
     * @param prefix Prefijo del servicio
     * @param identifier Identificador único
     * @param operation Operación (opcional)
     * @return Clave de cache formateada
     */
    public String generateCacheKey(String prefix, String identifier, String operation) {
        String key = operation != null && !operation.isEmpty() 
            ? String.format("%s:%s:%s", prefix, identifier, operation)
            : String.format("%s:%s", prefix, identifier);
        return key.toLowerCase().replace(" ", "_");
    }
    
    /**
     * Generar clave de cache sin operación
     */
    public String generateCacheKey(String prefix, String identifier) {
        return generateCacheKey(prefix, identifier, null);
    }
    
    private <T> String serializeData(T data) throws JsonProcessingException {
        return objectMapper.writeValueAsString(data);
    }
    
    private <T> T deserializeData(String data, Class<T> clazz) {
        try {
            return objectMapper.readValue(data, clazz);
        } catch (Exception e) {
            throw new RuntimeException("Error deserializing cache data", e);
        }
    }
}