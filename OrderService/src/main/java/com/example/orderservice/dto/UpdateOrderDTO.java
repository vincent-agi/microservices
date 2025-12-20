package com.example.orderservice.dto;

import java.math.BigDecimal;

/**
 * DTO for updating an Order
 */
public class UpdateOrderDTO {

    private String shippingAddress;
    private String billingAddress;
    private BigDecimal totalAmount;
    private String status;

    // Constructors
    public UpdateOrderDTO() {
    }

    // Getters and Setters
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
}
