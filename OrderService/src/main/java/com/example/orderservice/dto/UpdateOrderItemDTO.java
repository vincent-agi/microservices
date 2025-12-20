package com.example.orderservice.dto;

import java.math.BigDecimal;

/**
 * DTO for updating an OrderItem
 */
public class UpdateOrderItemDTO {

    private Integer quantity;
    private BigDecimal unitPrice;

    // Constructors
    public UpdateOrderItemDTO() {
    }

    // Getters and Setters
    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }
}
