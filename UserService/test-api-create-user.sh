#!/bin/bash

# Script pour tester la création d'un utilisateur (POST /users)
# Usage: ./test-api-create-user.sh

echo "🔵 Test: Création d'un nouvel utilisateur"
echo "==========================================="
echo ""

# Création d'un utilisateur
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com",
    "password": "SecurePassword123",
    "firstName": "John",
    "lastName": "Doe",
    "phone": "+33612345678"
  }' | jq '.'

echo ""
echo "==========================================="
echo ""

# Test avec un utilisateur minimal (seuls email et password sont requis)
echo "🔵 Test: Création d'un utilisateur minimal"
echo "==========================================="
echo ""

curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "jane.smith@example.com",
    "password": "AnotherSecure123"
  }' | jq '.'

echo ""
echo "==========================================="
echo ""

# Test avec un email déjà existant (doit retourner une erreur 409)
echo "🔵 Test: Tentative de création avec un email existant (doit échouer)"
echo "====================================================================="
echo ""

curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com",
    "password": "SecurePassword123"
  }' | jq '.'

echo ""
