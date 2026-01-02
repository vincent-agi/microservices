package com.example.orderservice.service;

import com.example.orderservice.client.UserServiceClient;
import com.example.orderservice.client.CartServiceClient;
import com.example.orderservice.dto.*;
import com.example.orderservice.entity.Order;
import com.example.orderservice.entity.OrderItem;
import com.example.orderservice.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Service class for Order business logic.
 * Handles CRUD operations and order management.
 * Communicates with UserService and CartService for validation and data retrieval.
 */
@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private UserServiceClient userServiceClient;

    @Autowired
    private CartServiceClient cartServiceClient;

    private static final DateTimeFormatter ORDER_NUMBER_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    /**
     * Generate a unique order number
     */
    private String generateOrderNumber() {
        String timestamp = LocalDateTime.now().format(ORDER_NUMBER_FORMATTER);
        String randomSuffix = String.valueOf((int) (Math.random() * 10000));
        return "ORD-" + timestamp + "-" + randomSuffix;
    }

    /**
     * Create a new order
     * Validates user existence via UserService before creating the order.
     */
    @Transactional
    public OrderDTO createOrder(CreateOrderDTO createOrderDTO) {
        // Validate user exists via UserService
        Integer userId = createOrderDTO.getUserId();
        if (userId != null && !userServiceClient.verifyUserExists(userId)) {
            throw new IllegalArgumentException("User validation failed. Please ensure the user exists.");
        }

        Order order = new Order();
        order.setOrderNumber(generateOrderNumber());
        order.setUserId(createOrderDTO.getUserId());
        order.setShippingAddress(createOrderDTO.getShippingAddress());
        order.setBillingAddress(createOrderDTO.getBillingAddress());
        order.setTotalAmount(createOrderDTO.getTotalAmount());
        order.setStatus(createOrderDTO.getStatus() != null ? createOrderDTO.getStatus() : "CREATED");

        // Add order items if provided
        if (createOrderDTO.getOrderItems() != null && !createOrderDTO.getOrderItems().isEmpty()) {
            for (CreateOrderItemDTO itemDTO : createOrderDTO.getOrderItems()) {
                OrderItem item = new OrderItem();
                item.setProductId(itemDTO.getProductId());
                item.setQuantity(itemDTO.getQuantity());
                item.setUnitPrice(itemDTO.getUnitPrice());
                item.calculateTotalLine();
                order.addOrderItem(item);
            }
        }

        Order savedOrder = orderRepository.save(order);
        return convertToDTO(savedOrder);
    }

    /**
     * Get all orders with pagination
     */
    public Page<OrderDTO> getAllOrders(int page, int limit, Integer userId, String status) {
        Pageable pageable = PageRequest.of(page - 1, limit);
        Page<Order> orders;

        if (userId != null && status != null) {
            orders = orderRepository.findByUserIdAndStatus(userId, status, pageable);
        } else if (userId != null) {
            orders = orderRepository.findByUserId(userId, pageable);
        } else if (status != null) {
            orders = orderRepository.findByStatus(status, pageable);
        } else {
            orders = orderRepository.findAll(pageable);
        }

        return orders.map(this::convertToDTOWithoutItems);
    }

    /**
     * Get order by ID
     */
    public Optional<OrderDTO> getOrderById(Long id) {
        return orderRepository.findById(id)
                .map(this::convertToDTO);
    }

    /**
     * Update an order
     */
    @Transactional
    public Optional<OrderDTO> updateOrder(Long id, UpdateOrderDTO updateOrderDTO) {
        return orderRepository.findById(id)
                .map(order -> {
                    if (updateOrderDTO.getShippingAddress() != null) {
                        order.setShippingAddress(updateOrderDTO.getShippingAddress());
                    }
                    if (updateOrderDTO.getBillingAddress() != null) {
                        order.setBillingAddress(updateOrderDTO.getBillingAddress());
                    }
                    if (updateOrderDTO.getTotalAmount() != null) {
                        order.setTotalAmount(updateOrderDTO.getTotalAmount());
                    }
                    if (updateOrderDTO.getStatus() != null) {
                        order.setStatus(updateOrderDTO.getStatus());
                    }
                    Order updatedOrder = orderRepository.save(order);
                    return convertToDTO(updatedOrder);
                });
    }

    /**
     * Delete an order
     */
    @Transactional
    public boolean deleteOrder(Long id) {
        if (orderRepository.existsById(id)) {
            orderRepository.deleteById(id);
            return true;
        }
        return false;
    }

    /**
     * Get orders by user ID with pagination
     */
    public Page<OrderDTO> getOrdersByUserId(Integer userId, int page, int limit) {
        Pageable pageable = PageRequest.of(page - 1, limit);
        return orderRepository.findByUserId(userId, pageable)
                .map(this::convertToDTOWithoutItems);
    }

    /**
     * Get enriched order data by fetching user and cart information from other services.
     * Demonstrates inter-service communication.
     * 
     * @param orderDTO The order to enrich
     * @return Map containing order data, user data, and cart data
     */
    public Map<String, Object> getEnrichedOrderData(OrderDTO orderDTO) {
        Map<String, Object> enrichedData = new HashMap<>();
        enrichedData.put("order", orderDTO);

        // Fetch user information from UserService
        if (orderDTO.getUserId() != null) {
            Object userData = userServiceClient.getUserInfo(orderDTO.getUserId());
            enrichedData.put("user", userData != null ? userData : Map.of("error", "User not found"));
        }

        // Fetch cart information from CartService
        if (orderDTO.getUserId() != null) {
            Object cartData = cartServiceClient.getCartByUserId(orderDTO.getUserId());
            enrichedData.put("userCarts", cartData != null ? cartData : Map.of("info", "No carts found"));
        }

        return enrichedData;
    }

    /**
     * Convert Order entity to DTO (with items)
     */
    private OrderDTO convertToDTO(Order order) {
        OrderDTO dto = new OrderDTO();
        dto.setId(order.getId());
        dto.setOrderNumber(order.getOrderNumber());
        dto.setUserId(order.getUserId());
        dto.setShippingAddress(order.getShippingAddress());
        dto.setBillingAddress(order.getBillingAddress());
        dto.setTotalAmount(order.getTotalAmount());
        dto.setStatus(order.getStatus());
        dto.setCreatedAt(order.getCreatedAt());
        dto.setUpdatedAt(order.getUpdatedAt());

        // Convert order items
        if (order.getOrderItems() != null) {
            List<OrderItemDTO> itemDTOs = order.getOrderItems().stream()
                    .map(this::convertItemToDTO)
                    .collect(Collectors.toList());
            dto.setOrderItems(itemDTOs);
        }

        return dto;
    }

    /**
     * Convert Order entity to DTO (without items for list views)
     */
    private OrderDTO convertToDTOWithoutItems(Order order) {
        OrderDTO dto = new OrderDTO();
        dto.setId(order.getId());
        dto.setOrderNumber(order.getOrderNumber());
        dto.setUserId(order.getUserId());
        dto.setShippingAddress(order.getShippingAddress());
        dto.setBillingAddress(order.getBillingAddress());
        dto.setTotalAmount(order.getTotalAmount());
        dto.setStatus(order.getStatus());
        dto.setCreatedAt(order.getCreatedAt());
        dto.setUpdatedAt(order.getUpdatedAt());
        return dto;
    }

    /**
     * Convert OrderItem entity to DTO
     */
    private OrderItemDTO convertItemToDTO(OrderItem item) {
        OrderItemDTO dto = new OrderItemDTO();
        dto.setId(item.getId());
        dto.setOrderId(item.getOrder().getId());
        dto.setProductId(item.getProductId());
        dto.setQuantity(item.getQuantity());
        dto.setUnitPrice(item.getUnitPrice());
        dto.setTotalLine(item.getTotalLine());
        dto.setCreatedAt(item.getCreatedAt());
        return dto;
    }
}
