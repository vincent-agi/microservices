#!/bin/bash

# Script to run all API tests for CartService
# Usage: ./run-all-tests.sh

echo "======================================================================"
echo "                  CartService API Tests Suite                       "
echo "======================================================================"
echo ""
echo "Starting comprehensive API tests..."
echo ""

# Test Orders endpoints
echo "======================================================================"
echo "                      ORDERS ENDPOINTS                                "
echo "======================================================================"
echo ""

./test-api-create-panier.sh
./test-api-create-article.sh

./test-api-read-articles.sh
./test-api-read-paniers.sh

./test-api-update-panier.sh
./test-api-update-article.sh

./test-api-delete-panier.sh
./test-api-delete-article.sh

echo "======================================================================"
echo "                      Tests Completed                                 "
echo "======================================================================"
echo ""
echo "All API tests have been executed."
echo "Please review the output above for any errors or unexpected responses."
echo ""
