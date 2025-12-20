#!/bin/bash

# Script to test creating order items (POST /api/order-items)
# Usage: ./test-api-create-orderitem.sh

echo "🔵 Test: Create a new order item"
echo "================================="
echo ""

# First, create an order to add items to
echo "Creating order first..."
CREATE_ORDER_RESPONSE=$(curl -s -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "shippingAddress": "123 Test St, City, Country",
    "billingAddress": "123 Test St, City, Country",
    "totalAmount": 0.00,
    "status": "CREATED"
  }')

echo "$CREATE_ORDER_RESPONSE"
echo ""

# Extract order ID
ORDER_ID=$(echo $CREATE_ORDER_RESPONSE | grep -o '"id":[0-9]*' | grep -o '[0-9]*' | head -1)

if [ -n "$ORDER_ID" ]; then
  echo "Order ID: $ORDER_ID"
  echo ""
  echo "Creating order item..."
  echo ""
  
  # Create order item
  curl -X POST http://localhost:8080/api/order-items \
    -H "Content-Type: application/json" \
    -d "{
      \"orderId\": $ORDER_ID,
      \"productId\": \"PROD-123\",
      \"quantity\": 2,
      \"unitPrice\": 49.99
    }"
  
  echo ""
  echo "==========================================="
  echo ""
  
  # Create another order item
  echo "🔵 Test: Create another order item"
  echo "==================================="
  echo ""
  
  curl -X POST http://localhost:8080/api/order-items \
    -H "Content-Type: application/json" \
    -d "{
      \"orderId\": $ORDER_ID,
      \"productId\": \"PROD-456\",
      \"quantity\": 1,
      \"unitPrice\": 99.99
    }"
  
  echo ""
else
  echo "Failed to create order or extract ID"
fi

echo ""
echo "==========================================="
echo ""

# Test creating order item with non-existent order
echo "🔵 Test: Create order item with non-existent order (should return 404)"
echo "======================================================================"
echo ""

curl -X POST http://localhost:8080/api/order-items \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": 9999,
    "productId": "PROD-999",
    "quantity": 1,
    "unitPrice": 10.00
  }'

echo ""
echo "==========================================="
echo ""

# Test validation error (missing required field)
echo "🔵 Test: Validation error (missing quantity)"
echo "============================================"
echo ""

curl -X POST http://localhost:8080/api/order-items \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": 1,
    "productId": "PROD-ERROR",
    "unitPrice": 10.00
  }'

echo ""
