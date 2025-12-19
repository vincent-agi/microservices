#!/bin/bash

# Script pour tester la création d'un article (POST /articles)
# Usage: ./test-api-create-article.sh

echo "🔵 Test: Création d'un article dans un panier"
echo "============================================="
echo ""

# Création d'un article
curl -X POST http://localhost:5001/articles \
  -H "Content-Type: application/json" \
  -d '{
    "panierId": 1,
    "productId": "PROD-123",
    "quantity": 2,
    "unitPrice": 29.99
  }'

echo ""
echo "==========================================="
echo ""

# Création d'un article avec un autre produit
echo "🔵 Test: Ajout d'un deuxième article au même panier"
echo "==================================================="
echo ""

curl -X POST http://localhost:5001/articles \
  -H "Content-Type: application/json" \
  -d '{
    "panierId": 1,
    "productId": "PROD-456",
    "quantity": 1,
    "unitPrice": 49.99
  }'

echo ""
echo "==========================================="
echo ""

# Création d'un article avec quantité plus élevée
echo "🔵 Test: Ajout d'un article avec quantité multiple"
echo "=================================================="
echo ""

curl -X POST http://localhost:5001/articles \
  -H "Content-Type: application/json" \
  -d '{
    "panierId": 1,
    "productId": "PROD-789",
    "quantity": 5,
    "unitPrice": 12.50
  }'

echo ""
echo "==========================================="
echo ""

# Test avec un panier inexistant (doit échouer)
echo "🔵 Test: Tentative d'ajout à un panier inexistant (doit échouer)"
echo "================================================================"
echo ""

curl -X POST http://localhost:5001/articles \
  -H "Content-Type: application/json" \
  -d '{
    "panierId": 9999,
    "productId": "PROD-999",
    "quantity": 1,
    "unitPrice": 10.00
  }'

echo ""
echo "==========================================="
echo ""

# Test avec quantité invalide (doit échouer)
echo "🔵 Test: Tentative avec quantité nulle (doit échouer)"
echo "====================================================="
echo ""

curl -X POST http://localhost:5001/articles \
  -H "Content-Type: application/json" \
  -d '{
    "panierId": 1,
    "productId": "PROD-000",
    "quantity": 0,
    "unitPrice": 10.00
  }'

echo ""
echo "==========================================="
echo ""

# Test avec prix négatif (doit échouer)
echo "🔵 Test: Tentative avec prix négatif (doit échouer)"
echo "==================================================="
echo ""

curl -X POST http://localhost:5001/articles \
  -H "Content-Type: application/json" \
  -d '{
    "panierId": 1,
    "productId": "PROD-NEG",
    "quantity": 1,
    "unitPrice": -5.00
  }'

echo ""
