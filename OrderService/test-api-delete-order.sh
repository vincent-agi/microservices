#!/bin/bash

# Script to test deleting orders (DELETE /api/orders/:id)
# Usage: ./test-api-delete-order.sh

echo "🔵 Test: Delete order by ID"
echo "============================"
echo ""

# First create an order to delete
echo "Creating order to delete..."
CREATE_RESPONSE=$(curl -s -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 99,
    "shippingAddress": "To be deleted, 999 Delete St, City, Country",
    "billingAddress": "To be deleted, 999 Delete St, City, Country",
    "totalAmount": 1.00,
    "status": "CREATED"
  }')

echo "$CREATE_RESPONSE"
echo ""
echo "Extracting order ID..."

# Extract order ID (simple extraction, assumes response format)
ORDER_ID=$(echo $CREATE_RESPONSE | grep -o '"id":[0-9]*' | grep -o '[0-9]*' | head -1)

if [ -n "$ORDER_ID" ]; then
  echo "Order ID: $ORDER_ID"
  echo ""
  echo "Deleting order..."
  echo ""
  
  # Delete the order
  curl -X DELETE http://localhost:8080/api/orders/$ORDER_ID
  
  echo ""
  echo "==========================================="
  echo ""
  
  # Try to get the deleted order (should return 404)
  echo "🔵 Test: Try to get deleted order (should return 404)"
  echo "====================================================="
  echo ""
  
  curl -X GET http://localhost:8080/api/orders/$ORDER_ID
  
  echo ""
else
  echo "Failed to create order or extract ID"
fi

echo ""
echo "==========================================="
echo ""

# Try to delete non-existent order
echo "🔵 Test: Delete non-existent order (ID=9999) - should return 404"
echo "================================================================"
echo ""

curl -X DELETE http://localhost:8080/api/orders/9999

echo ""
