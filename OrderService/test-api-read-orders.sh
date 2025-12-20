#!/bin/bash

# Script to test reading orders (GET /api/orders and GET /api/orders/:id)
# Usage: ./test-api-read-orders.sh

echo "🔵 Test: Get all orders (default pagination)"
echo "============================================="
echo ""

curl -X GET http://localhost:8080/api/orders

echo ""
echo "==========================================="
echo ""

# Get all orders with custom pagination
echo "🔵 Test: Get orders with custom pagination (page 1, limit 5)"
echo "============================================================="
echo ""

curl -X GET "http://localhost:8080/api/orders?page=1&limit=5"

echo ""
echo "==========================================="
echo ""

# Get orders page 2
echo "🔵 Test: Get orders page 2"
echo "=========================="
echo ""

curl -X GET "http://localhost:8080/api/orders?page=2&limit=5"

echo ""
echo "==========================================="
echo ""

# Get orders filtered by userId
echo "🔵 Test: Get orders filtered by userId=1"
echo "========================================"
echo ""

curl -X GET "http://localhost:8080/api/orders?userId=1"

echo ""
echo "==========================================="
echo ""

# Get orders filtered by status
echo "🔵 Test: Get orders filtered by status=CREATED"
echo "=============================================="
echo ""

curl -X GET "http://localhost:8080/api/orders?status=CREATED"

echo ""
echo "==========================================="
echo ""

# Get orders filtered by userId and status
echo "🔵 Test: Get orders filtered by userId=1 and status=CREATED"
echo "==========================================================="
echo ""

curl -X GET "http://localhost:8080/api/orders?userId=1&status=CREATED"

echo ""
echo "==========================================="
echo ""

# Get order by ID
echo "🔵 Test: Get order by ID (ID=1)"
echo "==============================="
echo ""

curl -X GET http://localhost:8080/api/orders/1

echo ""
echo "==========================================="
echo ""

# Get order by ID that doesn't exist
echo "🔵 Test: Get order by ID that doesn't exist (ID=9999) - should return 404"
echo "========================================================================="
echo ""

curl -X GET http://localhost:8080/api/orders/9999

echo ""
echo "==========================================="
echo ""

# Get orders by user ID via endpoint
echo "🔵 Test: Get orders via /api/orders/user/{userId}"
echo "=================================================="
echo ""

curl -X GET http://localhost:8080/api/orders/user/1

echo ""
echo "==========================================="
echo ""

# Health check
echo "🔵 Test: Health check endpoint"
echo "=============================="
echo ""

curl -X GET http://localhost:8080/api/orders/health

echo ""
