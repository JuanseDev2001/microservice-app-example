'use strict';

/**
 * Cache-Aside Pattern Implementation using Redis
 * 
 * Este módulo implementa el patrón Cache-Aside donde:
 * 1. La aplicación primero verifica si los datos están en cache
 * 2. Si no están (cache miss), consulta la fuente de datos original
 * 3. Guarda los datos en cache para futuras consultas
 * 4. Retorna los datos al cliente
 */

class CacheAsideService {
    constructor(redisClient, defaultTTL = 300) {
        this.redisClient = redisClient;
        this.defaultTTL = defaultTTL; // 5 minutes default
    }

    /**
     * Implementación del patrón Cache-Aside
     * @param {string} cacheKey - Clave única para el cache
     * @param {Function} dataFetcher - Función que obtiene los datos de la fuente original
     * @param {number} ttl - Tiempo de vida en segundos (opcional)
     * @returns {Promise} - Los datos solicitados
     */
    async getWithCacheAside(cacheKey, dataFetcher, ttl = this.defaultTTL) {
        try {
            // Paso 1: Verificar si los datos están en cache
            console.log(`[Cache-Aside] Checking cache for key: ${cacheKey}`);
            const cachedData = await this.redisClient.get(cacheKey);
            
            if (cachedData) {
                // Cache hit - retornar datos del cache
                console.log(`[Cache-Aside] Cache HIT for key: ${cacheKey}`);
                return JSON.parse(cachedData);
            }

            // Paso 2: Cache miss - obtener datos de la fuente original
            console.log(`[Cache-Aside] Cache MISS for key: ${cacheKey}, fetching from source`);
            const freshData = await dataFetcher();

            // Paso 3: Guardar en cache para futuras consultas
            if (freshData !== null && freshData !== undefined) {
                await this.redisClient.setEx(cacheKey, ttl, JSON.stringify(freshData));
                console.log(`[Cache-Aside] Data cached for key: ${cacheKey} with TTL: ${ttl}s`);
            }

            // Paso 4: Retornar datos al cliente
            return freshData;

        } catch (error) {
            console.error(`[Cache-Aside] Error for key ${cacheKey}:`, error);
            // Si hay error con cache, intentar obtener directamente de la fuente
            try {
                return await dataFetcher();
            } catch (fetchError) {
                console.error(`[Cache-Aside] Error fetching from source:`, fetchError);
                throw fetchError;
            }
        }
    }

    /**
     * Invalidar cache (útil para operaciones de escritura)
     * @param {string} cacheKey - Clave a invalidar
     */
    async invalidateCache(cacheKey) {
        try {
            await this.redisClient.del(cacheKey);
            console.log(`[Cache-Aside] Cache invalidated for key: ${cacheKey}`);
        } catch (error) {
            console.error(`[Cache-Aside] Error invalidating cache for key ${cacheKey}:`, error);
        }
    }

    /**
     * Invalidar múltiples claves de cache usando un patrón
     * @param {string} pattern - Patrón de claves a invalidar (ej: "user:*")
     */
    async invalidateCachePattern(pattern) {
        try {
            const keys = await this.redisClient.keys(pattern);
            if (keys.length > 0) {
                await this.redisClient.del(keys);
                console.log(`[Cache-Aside] Invalidated ${keys.length} cache keys matching pattern: ${pattern}`);
            }
        } catch (error) {
            console.error(`[Cache-Aside] Error invalidating cache pattern ${pattern}:`, error);
        }
    }

    /**
     * Generar clave de cache estandarizada
     * @param {string} prefix - Prefijo del servicio
     * @param {string} identifier - Identificador único
     * @param {string} operation - Operación (opcional)
     */
    generateCacheKey(prefix, identifier, operation = '') {
        const key = operation ? `${prefix}:${identifier}:${operation}` : `${prefix}:${identifier}`;
        return key.toLowerCase().replace(/\s+/g, '_');
    }
}

module.exports = CacheAsideService;