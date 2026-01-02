package com.example.orderservice.client;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.HttpClientErrorException;

/**
 * Client for communicating with UserService microservice.
 * Validates users by calling UserService REST API.
 */
@Component
public class UserServiceClient {

    @Value("${userservice.url:http://user-api-dev:3000}")
    private String userServiceUrl;

    private final RestTemplate restTemplate;

    public UserServiceClient() {
        this.restTemplate = new RestTemplate();
    }

    /**
     * Verify if a user exists in UserService.
     * 
     * @param userId The ID of the user to verify
     * @return true if user exists, false otherwise
     */
    public boolean verifyUserExists(Integer userId) {
        if (userId == null) {
            return false;
        }

        try {
            String url = userServiceUrl + "/users/" + userId;
            restTemplate.getForObject(url, Object.class);
            return true;
        } catch (HttpClientErrorException.NotFound e) {
            // User not found (404)
            return false;
        } catch (Exception e) {
            // Log error but don't fail the request
            // In production, you might want to handle this differently
            System.err.println("Error communicating with UserService: " + e.getMessage());
            // Return true to not block order creation if UserService is down
            // In production, you might want to fail instead or use circuit breaker
            return true;
        }
    }

    /**
     * Get user information from UserService.
     * 
     * @param userId The ID of the user
     * @return User data as a generic object, or null if not found
     */
    public Object getUserInfo(Integer userId) {
        if (userId == null) {
            return null;
        }

        try {
            String url = userServiceUrl + "/users/" + userId;
            return restTemplate.getForObject(url, Object.class);
        } catch (Exception e) {
            System.err.println("Error fetching user from UserService: " + e.getMessage());
            return null;
        }
    }
}
