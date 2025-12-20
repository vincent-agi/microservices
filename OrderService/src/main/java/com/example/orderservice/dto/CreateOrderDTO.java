package com.example.orderservice.dto;

import jakarta.validation.constraints.*;

import java.math.BigDecimal;
import java.util.List;

/**
 * DTO for creating a new Order
 */
public class CreateOrderDTO {

    @NotNull(message = "User ID is required")
    private Integer userId;

    @NotBlank(message = "Shipping address is required")
    @Size(max = 300, message = "Shipping address must not exceed 300 characters")
    private String shippingAddress;

    @NotBlank(message = "Billing address is required")
    @Size(max = 300, message = "Billing address must not exceed 300 characters")
    private String billingAddress;

    @NotNull(message = "Total amount is required")
    @DecimalMin(value = "0.0", inclusive = false, message = "Total amount must be greater than 0")
    private BigDecimal totalAmount;

    @Size(max = 50, message = "Status must not exceed 50 characters")
    private String status;

    private List<CreateOrderItemDTO> orderItems;

    // Constructors
    public CreateOrderDTO() {
    }

    // Getters and Setters
    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getShippingAddress() {
        return shippingAddress;
    }

    public void setShippingAddress(String shippingAddress) {
        this.shippingAddress = shippingAddress;
    }

    public String getBillingAddress() {
        return billingAddress;
    }

    public void setBillingAddress(String billingAddress) {
        this.billingAddress = billingAddress;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public List<CreateOrderItemDTO> getOrderItems() {
        return orderItems;
    }

    public void setOrderItems(List<CreateOrderItemDTO> orderItems) {
        this.orderItems = orderItems;
    }
}
