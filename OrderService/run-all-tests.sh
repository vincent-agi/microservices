#!/bin/bash

# Script to run all API tests for OrderService
# Usage: ./run-all-tests.sh

echo "======================================================================"
echo "                  OrderService API Tests Suite                       "
echo "======================================================================"
echo ""
echo "Starting comprehensive API tests..."
echo ""

./test-api-create-order.sh
./test-api-read-orders.sh
./test-api-update-order.sh
./test-api-delete-order.sh

./test-api-create-orderitem.sh
./test-api-read-orderitems.sh
./test-api-update-orderitem.sh
./test-api-delete-orderitem.sh

echo "======================================================================"
echo "                      Tests Completed                                 "
echo "======================================================================"
echo ""
echo "All API tests have been executed."
echo "Please review the output above for any errors or unexpected responses."
echo ""
