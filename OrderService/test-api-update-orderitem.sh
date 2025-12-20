#!/bin/bash

# Script to test updating order items (PUT /api/order-items/:id)
# Usage: ./test-api-update-orderitem.sh

echo "🔵 Test: Update order item quantity"
echo "===================================="
echo ""

# Update order item quantity
curl -X PUT http://localhost:8080/api/order-items/1 \
  -H "Content-Type: application/json" \
  -d '{
    "quantity": 5
  }'

echo ""
echo "==========================================="
echo ""

# Update order item unit price
echo "🔵 Test: Update order item unit price"
echo "======================================"
echo ""

curl -X PUT http://localhost:8080/api/order-items/1 \
  -H "Content-Type: application/json" \
  -d '{
    "unitPrice": 39.99
  }'

echo ""
echo "==========================================="
echo ""

# Update both quantity and unit price
echo "🔵 Test: Update both quantity and unit price"
echo "============================================="
echo ""

curl -X PUT http://localhost:8080/api/order-items/1 \
  -H "Content-Type: application/json" \
  -d '{
    "quantity": 3,
    "unitPrice": 44.99
  }'

echo ""
echo "==========================================="
echo ""

# Update non-existent order item (should return 404)
echo "🔵 Test: Update non-existent order item (ID=9999) - should return 404"
echo "====================================================================="
echo ""

curl -X PUT http://localhost:8080/api/order-items/9999 \
  -H "Content-Type: application/json" \
  -d '{
    "quantity": 10
  }'

echo ""
