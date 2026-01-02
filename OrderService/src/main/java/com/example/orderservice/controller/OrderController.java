package com.example.orderservice.controller;

import com.example.orderservice.dto.*;
import com.example.orderservice.service.OrderService;
import com.example.orderservice.util.ApiError;
import com.example.orderservice.util.ApiResponse;
import com.example.orderservice.util.PaginatedResponse;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * REST Controller for Order endpoints.
 * Provides CRUD operations for orders.
 */
@RestController
@RequestMapping("/api/orders")
public class OrderController {

    @Autowired
    private OrderService orderService;

    /**
     * Create a new order
     * POST /api/orders
     */
    @PostMapping
    public ResponseEntity<ApiResponse<OrderDTO>> createOrder(@Valid @RequestBody CreateOrderDTO createOrderDTO) {
        OrderDTO order = orderService.createOrder(createOrderDTO);
        return ResponseEntity.status(HttpStatus.CREATED).body(new ApiResponse<>(order));
    }

    /**
     * Get all orders with pagination and optional filters
     * GET /api/orders?page=1&limit=20&userId=1&status=CREATED
     */
    @GetMapping
    public ResponseEntity<PaginatedResponse<OrderDTO>> getAllOrders(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int limit,
            @RequestParam(required = false) Integer userId,
            @RequestParam(required = false) String status) {

        // Validate pagination parameters
        if (page < 1) page = 1;
        if (limit < 1) limit = 20;
        if (limit > 100) limit = 100;

        Page<OrderDTO> ordersPage = orderService.getAllOrders(page, limit, userId, status);
        PaginatedResponse<OrderDTO> response = new PaginatedResponse<>(
                ordersPage.getContent(),
                page,
                limit,
                ordersPage.getTotalElements()
        );

        return ResponseEntity.ok(response);
    }

    /**
     * Get order by ID
     * GET /api/orders/{id}
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> getOrderById(@PathVariable Long id) {
        Optional<OrderDTO> order = orderService.getOrderById(id);
        if (order.isPresent()) {
            return ResponseEntity.ok(new ApiResponse<>(order.get()));
        } else {
            Map<String, Object> details = new HashMap<>();
            details.put("orderId", id);
            ApiError error = new ApiError("NOT_FOUND", "Order with ID " + id + " not found", details);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        }
    }

    /**
     * Update an order
     * PUT /api/orders/{id}
     */
    @PutMapping("/{id}")
    public ResponseEntity<?> updateOrder(@PathVariable Long id, @RequestBody UpdateOrderDTO updateOrderDTO) {
        Optional<OrderDTO> updatedOrder = orderService.updateOrder(id, updateOrderDTO);
        if (updatedOrder.isPresent()) {
            return ResponseEntity.ok(new ApiResponse<>(updatedOrder.get()));
        } else {
            Map<String, Object> details = new HashMap<>();
            details.put("orderId", id);
            ApiError error = new ApiError("NOT_FOUND", "Order with ID " + id + " not found", details);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        }
    }

    /**
     * Delete an order
     * DELETE /api/orders/{id}
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteOrder(@PathVariable Long id) {
        boolean deleted = orderService.deleteOrder(id);
        if (deleted) {
            return ResponseEntity.noContent().build();
        } else {
            Map<String, Object> details = new HashMap<>();
            details.put("orderId", id);
            ApiError error = new ApiError("NOT_FOUND", "Order with ID " + id + " not found", details);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        }
    }

    /**
     * Get orders by user ID
     * GET /api/orders/user/{userId}?page=1&limit=20
     */
    @GetMapping("/user/{userId}")
    public ResponseEntity<PaginatedResponse<OrderDTO>> getOrdersByUserId(
            @PathVariable Integer userId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int limit) {

        // Validate pagination parameters
        if (page < 1) page = 1;
        if (limit < 1) limit = 20;
        if (limit > 100) limit = 100;

        Page<OrderDTO> ordersPage = orderService.getOrdersByUserId(userId, page, limit);
        PaginatedResponse<OrderDTO> response = new PaginatedResponse<>(
                ordersPage.getContent(),
                page,
                limit,
                ordersPage.getTotalElements()
        );

        return ResponseEntity.ok(response);
    }

    /**
     * Health check endpoint
     * GET /api/orders/health
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        return ResponseEntity.ok(Map.of(
                "status", "UP",
                "service", "OrderService"
        ));
    }

    /**
     * Get enriched order information with user and cart data from other services
     * GET /api/orders/{id}/enriched
     * Demonstrates inter-service communication
     */
    @GetMapping("/{id}/enriched")
    public ResponseEntity<?> getEnrichedOrder(@PathVariable Long id) {
        Optional<OrderDTO> orderOpt = orderService.getOrderById(id);
        if (orderOpt.isEmpty()) {
            Map<String, Object> details = new HashMap<>();
            details.put("orderId", id);
            ApiError error = new ApiError("NOT_FOUND", "Order with ID " + id + " not found", details);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        }

        OrderDTO order = orderOpt.get();
        Map<String, Object> enrichedData = orderService.getEnrichedOrderData(order);
        
        return ResponseEntity.ok(new ApiResponse<>(enrichedData));
    }

    /**
     * Exception handler for validation errors
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiError> handleValidationExceptions(MethodArgumentNotValidException ex) {
        Map<String, Object> details = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach(error -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            details.put(fieldName, errorMessage);
        });
        ApiError error = new ApiError("VALIDATION_ERROR", "Invalid input data", details);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

    /**
     * Global exception handler
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiError> handleGlobalException(Exception ex) {
        Map<String, Object> details = new HashMap<>();
        details.put("message", ex.getMessage());
        ApiError error = new ApiError("INTERNAL_SERVER_ERROR", "An unexpected error occurred", details);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }
}