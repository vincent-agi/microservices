package com.example.orderservice.repository;

import com.example.orderservice.entity.Order;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repository interface for Order entity.
 * Provides CRUD operations and custom queries.
 */
@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {

    /**
     * Find an order by its order number
     */
    Optional<Order> findByOrderNumber(String orderNumber);

    /**
     * Find orders by user ID with pagination
     */
    Page<Order> findByUserId(Integer userId, Pageable pageable);

    /**
     * Find orders by status with pagination
     */
    Page<Order> findByStatus(String status, Pageable pageable);

    /**
     * Find orders by user ID and status with pagination
     */
    Page<Order> findByUserIdAndStatus(Integer userId, String status, Pageable pageable);

    /**
     * Check if an order exists by order number
     */
    boolean existsByOrderNumber(String orderNumber);
}
