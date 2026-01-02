package com.example.orderservice.client;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
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

    private static final Logger logger = LoggerFactory.getLogger(CartServiceClient.class);

    @Value("${cartservice.url:http://cart-api-dev:5020}")
    private String cartServiceUrl;

    private final RestTemplate restTemplate;

    @Autowired
    public CartServiceClient(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
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
            Object cartData = restTemplate.getForObject(url, Object.class);
            logger.debug("Retrieved cart for user {} from CartService", userId);
            return cartData;
        } catch (HttpClientErrorException.NotFound e) {
            // Cart not found (404)
            logger.debug("No cart found for user {} in CartService", userId);
            return null;
        } catch (Exception e) {
            logger.error("Error communicating with CartService: {}", e.getMessage());
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
            Object cartData = restTemplate.getForObject(url, Object.class);
            logger.debug("Retrieved cart {} from CartService", cartId);
            return cartData;
        } catch (HttpClientErrorException.NotFound e) {
            // Cart not found (404)
            logger.debug("Cart {} not found in CartService", cartId);
            return null;
        } catch (Exception e) {
            logger.error("Error fetching cart from CartService: {}", e.getMessage());
            return null;
        }
    }
}
