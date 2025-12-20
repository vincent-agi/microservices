#!/bin/bash

# Script to run all API tests for all microservices
# Usage: ./run-all-tests.sh

echo "======================================================================"
echo "                  UserService API Tests Suite                       "
echo "======================================================================"
echo ""
echo "Starting comprehensive API tests..."
echo ""
cd ./UserService/ && ./run-all-tests.sh

echo "======================================================================"
echo "                  CartService API Tests Suite                       "
echo "======================================================================"
echo ""
echo "Starting comprehensive API tests..."
echo ""
cd ../CartService && ./run-all-tests.sh

echo "======================================================================"
echo "                  OrderService API Tests Suite                       "
echo "======================================================================"
echo ""
echo "Starting comprehensive API tests..."
echo ""
cd ../OrderService/ && ./run-all-tests.sh