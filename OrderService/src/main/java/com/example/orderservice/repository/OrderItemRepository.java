package com.example.orderservice.repository;

import com.example.orderservice.entity.OrderItem;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repository interface for OrderItem entity.
 * Provides CRUD operations and custom queries.
 */
@Repository
public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {

    /**
     * Find order items by order ID with pagination
     */
    Page<OrderItem> findByOrderId(Long orderId, Pageable pageable);

    /**
     * Find order items by product ID with pagination
     */
    Page<OrderItem> findByProductId(String productId, Pageable pageable);
}
