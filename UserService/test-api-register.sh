#!/bin/bash

# Script pour tester l'inscription d'un utilisateur (POST /auth/register)
# Usage: ./test-api-register.sh

echo "🔵 Test: Inscription d'un nouvel utilisateur"
echo "==========================================="
echo ""

# Inscription d'un utilisateur
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test.user@example.com",
    "password": "SecurePassword123",
    "firstName": "Test",
    "lastName": "User"
  }'

echo ""
echo "==========================================="
echo ""

# Test avec un autre utilisateur
echo "🔵 Test: Inscription d'un deuxième utilisateur"
echo "==========================================="
echo ""

curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice.martin@example.com",
    "password": "AlicePassword456",
    "firstName": "Alice",
    "lastName": "Martin"
  }'

echo ""
echo "==========================================="
echo ""

# Test avec un email déjà existant (doit retourner une erreur 409)
echo "🔵 Test: Tentative d'inscription avec un email existant (doit échouer)"
echo "====================================================================="
echo ""

curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test.user@example.com",
    "password": "AnotherPassword789",
    "firstName": "Test",
    "lastName": "Duplicate"
  }'

echo ""
echo "==========================================="
echo ""

# Test avec un mot de passe trop court (doit retourner une erreur 400)
echo "🔵 Test: Tentative d'inscription avec un mot de passe trop court (doit échouer)"
echo "==============================================================================="
echo ""

curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "short.password@example.com",
    "password": "123",
    "firstName": "Short",
    "lastName": "Password"
  }'

echo ""
