#!/bin/bash

# Script pour tester la mise à jour d'un panier (PUT /paniers/:id)
# Usage: ./test-api-update-panier.sh [PANIER_ID]
# Exemple: ./test-api-update-panier.sh 1

PANIER_ID=${1:-1}

echo "🔵 Test: Mise à jour du status d'un panier (ID=$PANIER_ID)"
echo "=========================================================="
echo ""

# Update du status
curl -X PUT http://localhost:5001/paniers/$PANIER_ID \
  -H "Content-Type: application/json" \
  -d '{
    "status": "completed"
  }'

echo ""
echo "==========================================="
echo ""

# Update du userId
echo "🔵 Test: Mise à jour du userId"
echo "=============================="
echo ""

curl -X PUT http://localhost:5001/paniers/$PANIER_ID \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 2
  }'

echo ""
echo "==========================================="
echo ""

# Update du status vers 'abandoned'
echo "🔵 Test: Changement du status vers 'abandoned'"
echo "=============================================="
echo ""

curl -X PUT http://localhost:5001/paniers/$PANIER_ID \
  -H "Content-Type: application/json" \
  -d '{
    "status": "abandoned"
  }'

echo ""
echo "==========================================="
echo ""

# Update multiple champs
echo "🔵 Test: Mise à jour de plusieurs champs simultanément"
echo "======================================================"
echo ""

curl -X PUT http://localhost:5001/paniers/$PANIER_ID \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "status": "active"
  }'

echo ""
echo "==========================================="
echo ""

# Test avec un ID inexistant (doit retourner 404)
echo "🔵 Test: Mise à jour d'un panier inexistant (doit échouer)"
echo "=========================================================="
echo ""

curl -X PUT http://localhost:5001/paniers/9999 \
  -H "Content-Type: application/json" \
  -d '{
    "status": "active"
  }'

echo ""
