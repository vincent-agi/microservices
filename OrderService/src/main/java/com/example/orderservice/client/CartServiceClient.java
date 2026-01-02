package com.example.orderservice.client;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.HttpClientErrorException;

/**
 * Client for communicating with CartService microservice.
 * Retrieves cart information from CartService.
 */
@Component
public class CartServiceClient {

    @Value("${cartservice.url:http://cart-api-dev:5020}")
    private String cartServiceUrl;

    private final RestTemplate restTemplate;

    public CartServiceClient() {
        this.restTemplate = new RestTemplate();
    }

    /**
     * Get cart information for a specific user from CartService.
     * 
     * @param userId The ID of the user
     * @return Cart data as a generic object, or null if not found
     */
    public Object getCartByUserId(Integer userId) {
        if (userId == null) {
            return null;
        }

        try {
            String url = cartServiceUrl + "/paniers/user/" + userId;
            return restTemplate.getForObject(url, Object.class);
        } catch (HttpClientErrorException.NotFound e) {
            // Cart not found (404)
            return null;
        } catch (Exception e) {
            System.err.println("Error communicating with CartService: " + e.getMessage());
            return null;
        }
    }

    /**
     * Get specific cart by ID from CartService.
     * 
     * @param cartId The ID of the cart
     * @return Cart data as a generic object, or null if not found
     */
    public Object getCartById(Integer cartId) {
        if (cartId == null) {
            return null;
        }

        try {
            String url = cartServiceUrl + "/paniers/" + cartId;
            return restTemplate.getForObject(url, Object.class);
        } catch (HttpClientErrorException.NotFound e) {
            // Cart not found (404)
            return null;
        } catch (Exception e) {
            System.err.println("Error fetching cart from CartService: " + e.getMessage());
            return null;
        }
    }
}
