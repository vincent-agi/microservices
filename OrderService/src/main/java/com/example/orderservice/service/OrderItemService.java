package com.example.orderservice.service;

import com.example.orderservice.dto.*;
import com.example.orderservice.entity.Order;
import com.example.orderservice.entity.OrderItem;
import com.example.orderservice.repository.OrderItemRepository;
import com.example.orderservice.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

/**
 * Service class for OrderItem business logic.
 * Handles CRUD operations for order items.
 */
@Service
public class OrderItemService {

    @Autowired
    private OrderItemRepository orderItemRepository;

    @Autowired
    private OrderRepository orderRepository;

    /**
     * Create a new order item
     */
    @Transactional
    public Optional<OrderItemDTO> createOrderItem(CreateOrderItemDTO createOrderItemDTO) {
        // Verify that the order exists
        Optional<Order> orderOpt = orderRepository.findById(createOrderItemDTO.getOrderId());
        if (orderOpt.isEmpty()) {
            return Optional.empty();
        }

        OrderItem orderItem = new OrderItem();
        orderItem.setOrder(orderOpt.get());
        orderItem.setProductId(createOrderItemDTO.getProductId());
        orderItem.setQuantity(createOrderItemDTO.getQuantity());
        orderItem.setUnitPrice(createOrderItemDTO.getUnitPrice());
        orderItem.calculateTotalLine();

        OrderItem savedItem = orderItemRepository.save(orderItem);
        return Optional.of(convertToDTO(savedItem));
    }

    /**
     * Get all order items with pagination
     */
    public Page<OrderItemDTO> getAllOrderItems(int page, int limit, Long orderId) {
        Pageable pageable = PageRequest.of(page - 1, limit);
        Page<OrderItem> items;

        if (orderId != null) {
            items = orderItemRepository.findByOrderId(orderId, pageable);
        } else {
            items = orderItemRepository.findAll(pageable);
        }

        return items.map(this::convertToDTO);
    }

    /**
     * Get order item by ID
     */
    public Optional<OrderItemDTO> getOrderItemById(Long id) {
        return orderItemRepository.findById(id)
                .map(this::convertToDTO);
    }

    /**
     * Update an order item
     */
    @Transactional
    public Optional<OrderItemDTO> updateOrderItem(Long id, UpdateOrderItemDTO updateOrderItemDTO) {
        return orderItemRepository.findById(id)
                .map(item -> {
                    if (updateOrderItemDTO.getQuantity() != null) {
                        item.setQuantity(updateOrderItemDTO.getQuantity());
                    }
                    if (updateOrderItemDTO.getUnitPrice() != null) {
                        item.setUnitPrice(updateOrderItemDTO.getUnitPrice());
                    }
                    item.calculateTotalLine();
                    OrderItem updatedItem = orderItemRepository.save(item);
                    return convertToDTO(updatedItem);
                });
    }

    /**
     * Delete an order item
     */
    @Transactional
    public boolean deleteOrderItem(Long id) {
        if (orderItemRepository.existsById(id)) {
            orderItemRepository.deleteById(id);
            return true;
        }
        return false;
    }

    /**
     * Get order items by order ID with pagination
     */
    public Page<OrderItemDTO> getOrderItemsByOrderId(Long orderId, int page, int limit) {
        Pageable pageable = PageRequest.of(page - 1, limit);
        return orderItemRepository.findByOrderId(orderId, pageable)
                .map(this::convertToDTO);
    }

    /**
     * Convert OrderItem entity to DTO
     */
    private OrderItemDTO convertToDTO(OrderItem item) {
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
