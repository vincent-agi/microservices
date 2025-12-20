#!/bin/bash

# Script to run all API tests for UserService
# Usage: ./run-all-tests.sh

echo "======================================================================"
echo "                  UserService API Tests Suite                       "
echo "======================================================================"
echo ""
echo "Starting comprehensive API tests..."
echo ""

./test-api-register.sh
./test-api-login.sh
./test-api-create-user.sh
./test-api-read-user.sh
./test-api-update-user.sh
./test-api-delete-user.sh

echo "======================================================================"
echo "                      Tests Completed                                 "
echo "======================================================================"
echo ""
echo "All API tests have been executed."
echo "Please review the output above for any errors or unexpected responses."
echo ""
