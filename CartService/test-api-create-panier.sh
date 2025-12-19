#!/bin/bash

# Script pour tester la création d'un panier (POST /paniers)
# Usage: ./test-api-create-panier.sh

echo "🔵 Test: Création d'un nouveau panier avec userId"
echo "=================================================="
echo ""

# Création d'un panier avec userId
curl -X POST http://localhost:5001/paniers \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "status": "active"
  }'

echo ""
echo "==========================================="
echo ""

# Test avec un panier minimal (sans userId - panier anonyme)
echo "🔵 Test: Création d'un panier anonyme"
echo "====================================="
echo ""

curl -X POST http://localhost:5001/paniers \
  -H "Content-Type: application/json" \
  -d '{
    "status": "active"
  }'

echo ""
echo "==========================================="
echo ""

# Test avec status différent
echo "🔵 Test: Création d'un panier avec status 'completed'"
echo "====================================================="
echo ""

curl -X POST http://localhost:5001/paniers \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "status": "completed"
  }'

echo ""
echo "==========================================="
echo ""

# Test avec userId inexistant (doit échouer si UserService est disponible)
echo "🔵 Test: Tentative de création avec un userId inexistant (peut échouer)"
echo "======================================================================="
echo ""

curl -X POST http://localhost:5001/paniers \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 9999,
    "status": "active"
  }'

echo ""
