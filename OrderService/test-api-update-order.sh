#!/bin/bash

# Script to test updating orders (PUT /api/orders/:id)
# Usage: ./test-api-update-order.sh

echo "🔵 Test: Update order status"
echo "============================="
echo ""

# Update order status
curl -X PUT http://localhost:8080/api/orders/1 \
  -H "Content-Type: application/json" \
  -d '{
    "status": "PAID"
  }'

echo ""
echo "==========================================="
echo ""

# Update order addresses
echo "🔵 Test: Update order shipping and billing addresses"
echo "====================================================="
echo ""

curl -X PUT http://localhost:8080/api/orders/1 \
  -H "Content-Type: application/json" \
  -d '{
    "shippingAddress": "Updated Shipping Address, 999 New St, City, Country",
    "billingAddress": "Updated Billing Address, 999 New St, City, Country"
  }'

echo ""
echo "==========================================="
echo ""

# Update order total amount
echo "🔵 Test: Update order total amount"
echo "==================================="
echo ""

curl -X PUT http://localhost:8080/api/orders/1 \
  -H "Content-Type: application/json" \
  -d '{
    "totalAmount": 199.99
  }'

echo ""
echo "==========================================="
echo ""

# Update multiple fields
echo "🔵 Test: Update multiple fields at once"
echo "========================================"
echo ""

curl -X PUT http://localhost:8080/api/orders/1 \
  -H "Content-Type: application/json" \
  -d '{
    "shippingAddress": "123 Final St, City, Country",
    "billingAddress": "123 Final St, City, Country",
    "totalAmount": 249.99,
    "status": "SHIPPED"
  }'

echo ""
echo "==========================================="
echo ""

# Update non-existent order (should return 404)
echo "🔵 Test: Update non-existent order (ID=9999) - should return 404"
echo "================================================================"
echo ""

curl -X PUT http://localhost:8080/api/orders/9999 \
  -H "Content-Type: application/json" \
  -d '{
    "status": "PAID"
  }'

echo ""
