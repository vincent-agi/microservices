package com.example.orderservice.controller;

import com.example.orderservice.dto.*;
import com.example.orderservice.service.OrderItemService;
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
import java.util.Map;
import java.util.Optional;

/**
 * REST Controller for OrderItem endpoints.
 * Provides CRUD operations for order items.
 */
@RestController
@RequestMapping("/api/order-items")
public class OrderItemController {

    @Autowired
    private OrderItemService orderItemService;

    /**
     * Create a new order item
     * POST /api/order-items
     */
    @PostMapping
    public ResponseEntity<?> createOrderItem(@Valid @RequestBody CreateOrderItemDTO createOrderItemDTO) {
        Optional<OrderItemDTO> orderItem = orderItemService.createOrderItem(createOrderItemDTO);
        if (orderItem.isPresent()) {
            return ResponseEntity.status(HttpStatus.CREATED).body(new ApiResponse<>(orderItem.get()));
        } else {
            Map<String, Object> details = new HashMap<>();
            details.put("orderId", createOrderItemDTO.getOrderId());
            ApiError error = new ApiError("NOT_FOUND", "Order with ID " + createOrderItemDTO.getOrderId() + " not found", details);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        }
    }

    /**
     * Get all order items with pagination and optional filters
     * GET /api/order-items?page=1&limit=20&orderId=1
     */
    @GetMapping
    public ResponseEntity<PaginatedResponse<OrderItemDTO>> getAllOrderItems(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int limit,
            @RequestParam(required = false) Long orderId) {

        // Validate pagination parameters
        if (page < 1) page = 1;
        if (limit < 1) limit = 20;
        if (limit > 100) limit = 100;

        Page<OrderItemDTO> itemsPage = orderItemService.getAllOrderItems(page, limit, orderId);
        PaginatedResponse<OrderItemDTO> response = new PaginatedResponse<>(
                itemsPage.getContent(),
                page,
                limit,
                itemsPage.getTotalElements()
        );

        return ResponseEntity.ok(response);
    }

    /**
     * Get order item by ID
     * GET /api/order-items/{id}
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> getOrderItemById(@PathVariable Long id) {
        Optional<OrderItemDTO> orderItem = orderItemService.getOrderItemById(id);
        if (orderItem.isPresent()) {
            return ResponseEntity.ok(new ApiResponse<>(orderItem.get()));
        } else {
            Map<String, Object> details = new HashMap<>();
            details.put("orderItemId", id);
            ApiError error = new ApiError("NOT_FOUND", "Order item with ID " + id + " not found", details);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        }
    }

    /**
     * Update an order item
     * PUT /api/order-items/{id}
     */
    @PutMapping("/{id}")
    public ResponseEntity<?> updateOrderItem(@PathVariable Long id, @RequestBody UpdateOrderItemDTO updateOrderItemDTO) {
        Optional<OrderItemDTO> updatedItem = orderItemService.updateOrderItem(id, updateOrderItemDTO);
        if (updatedItem.isPresent()) {
            return ResponseEntity.ok(new ApiResponse<>(updatedItem.get()));
        } else {
            Map<String, Object> details = new HashMap<>();
            details.put("orderItemId", id);
            ApiError error = new ApiError("NOT_FOUND", "Order item with ID " + id + " not found", details);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        }
    }

    /**
     * Delete an order item
     * DELETE /api/order-items/{id}
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteOrderItem(@PathVariable Long id) {
        boolean deleted = orderItemService.deleteOrderItem(id);
        if (deleted) {
            return ResponseEntity.noContent().build();
        } else {
            Map<String, Object> details = new HashMap<>();
            details.put("orderItemId", id);
            ApiError error = new ApiError("NOT_FOUND", "Order item with ID " + id + " not found", details);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        }
    }

    /**
     * Get order items by order ID
     * GET /api/order-items/order/{orderId}?page=1&limit=20
     */
    @GetMapping("/order/{orderId}")
    public ResponseEntity<PaginatedResponse<OrderItemDTO>> getOrderItemsByOrderId(
            @PathVariable Long orderId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int limit) {

        // Validate pagination parameters
        if (page < 1) page = 1;
        if (limit < 1) limit = 20;
        if (limit > 100) limit = 100;

        Page<OrderItemDTO> itemsPage = orderItemService.getOrderItemsByOrderId(orderId, page, limit);
        PaginatedResponse<OrderItemDTO> response = new PaginatedResponse<>(
                itemsPage.getContent(),
                page,
                limit,
                itemsPage.getTotalElements()
        );

        return ResponseEntity.ok(response);
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
