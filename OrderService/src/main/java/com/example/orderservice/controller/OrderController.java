package com.example.orderservice.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    @GetMapping("/health")
    public Map<String, Object> health() {
        return Map.of(
                "status", "UP",
                "service", "OrderService",
                "timestamp", LocalDateTime.now()
        );
    }

    @GetMapping
    public Map<String, Object> getOrders() {
        return Map.of(
                "message", "OrderService is running",
                "orders", "[]",
                "timestamp", LocalDateTime.now()
        );
    }
}