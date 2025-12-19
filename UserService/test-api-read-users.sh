#!/bin/bash

# Script pour tester la lecture des utilisateurs (GET /users et GET /users/:id)
# Usage: ./test-api-read-users.sh

echo "🔵 Test: Récupération de tous les utilisateurs (avec pagination par défaut)"
echo "==========================================================================="
echo ""

# GET all users (page 1, limit 20 par défaut)
curl -X GET http://localhost:3000/users

echo ""
echo "==========================================="
echo ""

# GET all users avec pagination personnalisée
echo "🔵 Test: Récupération avec pagination personnalisée (page 1, limit 5)"
echo "====================================================================="
echo ""

curl -X GET "http://localhost:3000/users?page=1&limit=5"

echo ""
echo "==========================================="
echo ""

# GET all users - page 2
echo "🔵 Test: Récupération de la page 2"
echo "================================="
echo ""

curl -X GET "http://localhost:3000/users?page=2&limit=5"

echo ""
echo "==========================================="
echo ""

# GET user by ID
echo "🔵 Test: Récupération d'un utilisateur par ID (ID=1)"
echo "===================================================="
echo ""

curl -X GET http://localhost:3000/users/1

echo ""
echo "==========================================="
echo ""

# GET user by ID qui n'existe pas (doit retourner 404)
echo "🔵 Test: Récupération d'un utilisateur inexistant (ID=9999) - doit échouer"
echo "=========================================================================="
echo ""

curl -X GET http://localhost:3000/users/9999

echo ""
