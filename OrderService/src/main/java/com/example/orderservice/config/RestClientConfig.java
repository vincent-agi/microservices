package com.example.orderservice.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

/**
 * Configuration class for REST client beans.
 * Provides RestTemplate bean for inter-service communication.
 */
@Configuration
public class RestClientConfig {

    /**
     * Create RestTemplate bean for HTTP client operations.
     * Used by service clients (UserServiceClient, CartServiceClient) to communicate
     * with other microservices.
     * 
     * @return RestTemplate instance
     */
    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
