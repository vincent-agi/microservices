#!/bin/bash

# Script to test creating orders (POST /api/orders)
# Usage: ./test-api-create-order.sh

echo "🔵 Test: Create a new order"
echo "============================"
echo ""

# Create an order with all required fields
curl -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "shippingAddress": "123 Main St, City, Country",
    "billingAddress": "123 Main St, City, Country",
    "totalAmount": 99.99,
    "status": "CREATED"
  }'

echo ""
echo "==========================================="
echo ""

# Create an order with order items
echo "🔵 Test: Create an order with items"
echo "===================================="
echo ""

curl -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "shippingAddress": "456 Oak Ave, Town, Country",
    "billingAddress": "456 Oak Ave, Town, Country",
    "totalAmount": 149.98,
    "status": "CREATED",
    "orderItems": [
      {
        "productId": "PROD-001",
        "quantity": 2,
        "unitPrice": 49.99
      },
      {
        "productId": "PROD-002",
        "quantity": 1,
        "unitPrice": 50.00
      }
    ]
  }'

echo ""
echo "==========================================="
echo ""

# Create an order with different status
echo "🔵 Test: Create an order with PAID status"
echo "=========================================="
echo ""

curl -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 2,
    "shippingAddress": "789 Pine Rd, Village, Country",
    "billingAddress": "789 Pine Rd, Village, Country",
    "totalAmount": 299.99,
    "status": "PAID"
  }'

echo ""
echo "==========================================="
echo ""

# Test validation error (missing required field)
echo "🔵 Test: Validation error (missing shipping address)"
echo "===================================================="
echo ""

curl -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "billingAddress": "123 Main St, City, Country",
    "totalAmount": 99.99
  }'

echo ""
