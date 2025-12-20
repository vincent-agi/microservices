#!/bin/bash

# Script to run all API tests for OrderService
# Usage: ./run-all-tests.sh

echo "======================================================================"
echo "                  OrderService API Tests Suite                       "
echo "======================================================================"
echo ""
echo "Starting comprehensive API tests..."
echo ""

# Test Orders endpoints
echo "======================================================================"
echo "                      ORDERS ENDPOINTS                                "
echo "======================================================================"
echo ""

echo "--- CREATE ORDERS ---"
./test-api-create-order.sh
echo ""

echo "--- READ ORDERS ---"
./test-api-read-orders.sh
echo ""

echo "--- UPDATE ORDERS ---"
./test-api-update-order.sh
echo ""

echo "--- DELETE ORDERS ---"
./test-api-delete-order.sh
echo ""

# Test OrderItems endpoints
echo "======================================================================"
echo "                    ORDER ITEMS ENDPOINTS                             "
echo "======================================================================"
echo ""

echo "--- CREATE ORDER ITEMS ---"
./test-api-create-orderitem.sh
echo ""

echo "--- READ ORDER ITEMS ---"
./test-api-read-orderitems.sh
echo ""

echo "--- UPDATE ORDER ITEMS ---"
./test-api-update-orderitem.sh
echo ""

echo "--- DELETE ORDER ITEMS ---"
./test-api-delete-orderitem.sh
echo ""

echo "======================================================================"
echo "                      Tests Completed                                 "
echo "======================================================================"
echo ""
echo "All API tests have been executed."
echo "Please review the output above for any errors or unexpected responses."
echo ""
