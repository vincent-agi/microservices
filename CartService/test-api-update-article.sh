#!/bin/bash

# Script pour tester la mise à jour d'un article (PUT /articles/:id)
# Usage: ./test-api-update-article.sh [ARTICLE_ID]
# Exemple: ./test-api-update-article.sh 1

ARTICLE_ID=${1:-1}

echo "🔵 Test: Mise à jour de la quantité d'un article (ID=$ARTICLE_ID)"
echo "================================================================="
echo ""

# Update de la quantité
curl -X PUT http://localhost:5001/articles/$ARTICLE_ID \
  -H "Content-Type: application/json" \
  -d '{
    "quantity": 5
  }'

echo ""
echo "==========================================="
echo ""

# Update du prix unitaire
echo "🔵 Test: Mise à jour du prix unitaire"
echo "====================================="
echo ""

curl -X PUT http://localhost:5001/articles/$ARTICLE_ID \
  -H "Content-Type: application/json" \
  -d '{
    "unitPrice": 24.99
  }'

echo ""
echo "==========================================="
echo ""

# Update du productId
echo "🔵 Test: Mise à jour du productId"
echo "================================="
echo ""

curl -X PUT http://localhost:5001/articles/$ARTICLE_ID \
  -H "Content-Type: application/json" \
  -d '{
    "productId": "PROD-999"
  }'

echo ""
echo "==========================================="
echo ""

# Update multiple champs
echo "🔵 Test: Mise à jour de plusieurs champs simultanément"
echo "======================================================"
echo ""

curl -X PUT http://localhost:5001/articles/$ARTICLE_ID \
  -H "Content-Type: application/json" \
  -d '{
    "quantity": 3,
    "unitPrice": 19.99
  }'

echo ""
echo "==========================================="
echo ""

# Test avec quantité invalide (doit échouer)
echo "🔵 Test: Tentative avec quantité nulle (doit échouer)"
echo "====================================================="
echo ""

curl -X PUT http://localhost:5001/articles/$ARTICLE_ID \
  -H "Content-Type: application/json" \
  -d '{
    "quantity": 0
  }'

echo ""
echo "==========================================="
echo ""

# Test avec prix négatif (doit échouer)
echo "🔵 Test: Tentative avec prix négatif (doit échouer)"
echo "==================================================="
echo ""

curl -X PUT http://localhost:5001/articles/$ARTICLE_ID \
  -H "Content-Type: application/json" \
  -d '{
    "unitPrice": -10.00
  }'

echo ""
echo "==========================================="
echo ""

# Test avec un ID inexistant (doit retourner 404)
echo "🔵 Test: Mise à jour d'un article inexistant (doit échouer)"
echo "==========================================================="
echo ""

curl -X PUT http://localhost:5001/articles/9999 \
  -H "Content-Type: application/json" \
  -d '{
    "quantity": 1
  }'

echo ""
