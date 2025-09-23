package com.elgris.usersapi.service;

import com.elgris.usersapi.models.User;
import com.elgris.usersapi.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

@Service
public class UserService {
    
    private static final Logger logger = LoggerFactory.getLogger(UserService.class);
    private static final String USER_CACHE_KEY = "user:";
    private static final String ALL_USERS_CACHE_KEY = "users:all";
    private static final long CACHE_TTL = 300; // 5 minutes
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private RedisTemplate<String, Object> redisTemplate;
    
    /**
     * Cache-Aside pattern for single user retrieval
     * 1. Try to get from cache
     * 2. If cache miss, get from database
     * 3. Store in cache for future requests
     */
    public User getUserByUsername(String username) {
        String cacheKey = USER_CACHE_KEY + username;
        
        try {
            // Step 1: Try to get from cache (Cache-Aside pattern)
            User cachedUser = (User) redisTemplate.opsForValue().get(cacheKey);
            
            if (cachedUser != null) {
                logger.info("Cache HIT for user: {}", username);
                return cachedUser;
            }
            
            // Step 2: Cache miss - get from database
            logger.info("Cache MISS for user: {}", username);
            User user = userRepository.findOneByUsername(username);
            
            if (user != null) {
                // Step 3: Store in cache with TTL
                redisTemplate.opsForValue().set(cacheKey, user, CACHE_TTL, TimeUnit.SECONDS);
                logger.info("User cached successfully: {}", username);
            }
            
            return user;
            
        } catch (Exception e) {
            // Cache failure fallback - get directly from database
            logger.warn("Cache operation failed for user: {}. Fallback to database. Error: {}", 
                       username, e.getMessage());
            return userRepository.findOneByUsername(username);
        }
    }
    
    /**
     * Cache-Aside pattern for all users retrieval
     */
    public List<User> getAllUsers() {
        try {
            // Step 1: Try to get from cache
            List<User> cachedUsers = (List<User>) redisTemplate.opsForValue().get(ALL_USERS_CACHE_KEY);
            
            if (cachedUsers != null && !cachedUsers.isEmpty()) {
                logger.info("Cache HIT for all users");
                return cachedUsers;
            }
            
            // Step 2: Cache miss - get from database
            logger.info("Cache MISS for all users");
            List<User> users = new ArrayList<>();
            userRepository.findAll().forEach(users::add);
            
            if (!users.isEmpty()) {
                // Step 3: Store in cache with TTL
                redisTemplate.opsForValue().set(ALL_USERS_CACHE_KEY, users, CACHE_TTL, TimeUnit.SECONDS);
                logger.info("All users cached successfully. Count: {}", users.size());
            }
            
            return users;
            
        } catch (Exception e) {
            // Cache failure fallback - get directly from database
            logger.warn("Cache operation failed for all users. Fallback to database. Error: {}", 
                       e.getMessage());
            List<User> users = new ArrayList<>();
            userRepository.findAll().forEach(users::add);
            return users;
        }
    }
    
    /**
     * Invalidate cache for specific user (useful for updates)
     */
    public void invalidateUserCache(String username) {
        try {
            String cacheKey = USER_CACHE_KEY + username;
            redisTemplate.delete(cacheKey);
            logger.info("Cache invalidated for user: {}", username);
        } catch (Exception e) {
            logger.warn("Failed to invalidate cache for user: {}. Error: {}", username, e.getMessage());
        }
    }
    
    /**
     * Invalidate all users cache
     */
    public void invalidateAllUsersCache() {
        try {
            redisTemplate.delete(ALL_USERS_CACHE_KEY);
            logger.info("All users cache invalidated");
        } catch (Exception e) {
            logger.warn("Failed to invalidate all users cache. Error: {}", e.getMessage());
        }
    }
    
    /**
     * Get cache statistics for monitoring
     */
    public String getCacheStats() {
        try {
            boolean allUsersExists = Boolean.TRUE.equals(redisTemplate.hasKey(ALL_USERS_CACHE_KEY));
            Long allUserssTTL = redisTemplate.getExpire(ALL_USERS_CACHE_KEY);
            
            return String.format("Cache Stats - All Users Exists: %s, TTL: %d seconds", 
                                allUsersExists, allUserssTTL);
        } catch (Exception e) {
            return "Cache stats unavailable: " + e.getMessage();
        }
    }
}