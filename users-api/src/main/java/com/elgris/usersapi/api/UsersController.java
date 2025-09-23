package com.elgris.usersapi.api;

import com.elgris.usersapi.models.User;
import com.elgris.usersapi.service.UserService;
import io.jsonwebtoken.Claims;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

@RestController()
@RequestMapping("/users")
public class UsersController {

    @Autowired
    private UserService userService;

    @RequestMapping(value = "/", method = RequestMethod.GET)
    public List<User> getUsers() {
        // Using Cache-Aside pattern through UserService
        return userService.getAllUsers();
    }

    @RequestMapping(value = "/{username}",  method = RequestMethod.GET)
    public User getUser(HttpServletRequest request, @PathVariable("username") String username) {

        Object requestAttribute = request.getAttribute("claims");
        if((requestAttribute == null) || !(requestAttribute instanceof Claims)){
            throw new RuntimeException("Did not receive required data from JWT token");
        }

        Claims claims = (Claims) requestAttribute;

        if (!username.equalsIgnoreCase((String)claims.get("username"))) {
            throw new AccessDeniedException("No access for requested entity");
        }

        // Using Cache-Aside pattern through UserService
        return userService.getUserByUsername(username);
    }

    /**
     * New endpoint to get cache statistics for monitoring
     */
    @RequestMapping(value = "/cache/stats", method = RequestMethod.GET)
    public String getCacheStats() {
        return userService.getCacheStats();
    }

    /**
     * New endpoint to manually invalidate cache (for testing/admin purposes)
     */
    @RequestMapping(value = "/cache/invalidate/{username}", method = RequestMethod.DELETE)
    public String invalidateUserCache(@PathVariable("username") String username) {
        userService.invalidateUserCache(username);
        return "Cache invalidated for user: " + username;
    }

    /**
     * New endpoint to manually invalidate all users cache
     */
    @RequestMapping(value = "/cache/invalidate", method = RequestMethod.DELETE)
    public String invalidateAllCache() {
        userService.invalidateAllUsersCache();
        return "All users cache invalidated";
    }

}
