#!/bin/bash

# Script to test deleting order items (DELETE /api/order-items/:id)
# Usage: ./test-api-delete-orderitem.sh

echo "🔵 Test: Delete order item by ID"
echo "================================="
echo ""

# First create an order item to delete
echo "Creating order item to delete..."

# First create an order
CREATE_ORDER_RESPONSE=$(curl -s -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 99,
    "shippingAddress": "To be deleted, 999 Delete St, City, Country",
    "billingAddress": "To be deleted, 999 Delete St, City, Country",
    "totalAmount": 1.00,
    "status": "CREATED"
  }')

ORDER_ID=$(echo $CREATE_ORDER_RESPONSE | grep -o '"id":[0-9]*' | grep -o '[0-9]*' | head -1)

if [ -n "$ORDER_ID" ]; then
  # Create order item
  CREATE_ITEM_RESPONSE=$(curl -s -X POST http://localhost:8080/api/order-items \
    -H "Content-Type: application/json" \
    -d "{
      \"orderId\": $ORDER_ID,
      \"productId\": \"PROD-DELETE\",
      \"quantity\": 1,
      \"unitPrice\": 1.00
    }")
  
  echo "$CREATE_ITEM_RESPONSE"
  echo ""
  
  # Extract order item ID
  ITEM_ID=$(echo $CREATE_ITEM_RESPONSE | grep -o '"id":[0-9]*' | grep -o '[0-9]*' | head -1)
  
  if [ -n "$ITEM_ID" ]; then
    echo "Order Item ID: $ITEM_ID"
    echo ""
    echo "Deleting order item..."
    echo ""
    
    # Delete the order item
    curl -X DELETE http://localhost:8080/api/order-items/$ITEM_ID
    
    echo ""
    echo "==========================================="
    echo ""
    
    # Try to get the deleted order item (should return 404)
    echo "🔵 Test: Try to get deleted order item (should return 404)"
    echo "==========================================================="
    echo ""
    
    curl -X GET http://localhost:8080/api/order-items/$ITEM_ID
    
    echo ""
  else
    echo "Failed to create order item or extract ID"
  fi
else
  echo "Failed to create order or extract ID"
fi

echo ""
echo "==========================================="
echo ""

# Try to delete non-existent order item
echo "🔵 Test: Delete non-existent order item (ID=9999) - should return 404"
echo "====================================================================="
echo ""

curl -X DELETE http://localhost:8080/api/order-items/9999

echo ""
