#!/bin/bash

# Script to test reading order items (GET /api/order-items and GET /api/order-items/:id)
# Usage: ./test-api-read-orderitems.sh

echo "🔵 Test: Get all order items (default pagination)"
echo "=================================================="
echo ""

curl -X GET http://localhost:8080/api/order-items

echo ""
echo "==========================================="
echo ""

# Get all order items with custom pagination
echo "🔵 Test: Get order items with custom pagination (page 1, limit 5)"
echo "=================================================================="
echo ""

curl -X GET "http://localhost:8080/api/order-items?page=1&limit=5"

echo ""
echo "==========================================="
echo ""

# Get order items page 2
echo "🔵 Test: Get order items page 2"
echo "================================"
echo ""

curl -X GET "http://localhost:8080/api/order-items?page=2&limit=5"

echo ""
echo "==========================================="
echo ""

# Get order items filtered by orderId
echo "🔵 Test: Get order items filtered by orderId=1"
echo "=============================================="
echo ""

curl -X GET "http://localhost:8080/api/order-items?orderId=1"

echo ""
echo "==========================================="
echo ""

# Get order item by ID
echo "🔵 Test: Get order item by ID (ID=1)"
echo "===================================="
echo ""

curl -X GET http://localhost:8080/api/order-items/1

echo ""
echo "==========================================="
echo ""

# Get order item by ID that doesn't exist
echo "🔵 Test: Get order item by ID that doesn't exist (ID=9999) - should return 404"
echo "=============================================================================="
echo ""

curl -X GET http://localhost:8080/api/order-items/9999

echo ""
echo "==========================================="
echo ""

# Get order items by order ID via endpoint
echo "🔵 Test: Get order items via /api/order-items/order/{orderId}"
echo "=============================================================="
echo ""

curl -X GET http://localhost:8080/api/order-items/order/1

echo ""
