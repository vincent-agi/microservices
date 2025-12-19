#!/bin/bash

# Script pour tester la lecture des articles (GET /articles et GET /articles/:id)
# Usage: ./test-api-read-articles.sh

echo "🔵 Test: Récupération de tous les articles (avec pagination par défaut)"
echo "========================================================================"
echo ""

# GET all articles (page 1, limit 20 par défaut)
curl -X GET http://localhost:5001/articles | jq '.'

echo ""
echo "==========================================="
echo ""

# GET all articles avec pagination personnalisée
echo "🔵 Test: Récupération avec pagination personnalisée (page 1, limit 5)"
echo "====================================================================="
echo ""

curl -X GET "http://localhost:5001/articles?page=1&limit=5" | jq '.'

echo ""
echo "==========================================="
echo ""

# GET all articles - page 2
echo "🔵 Test: Récupération de la page 2"
echo "================================="
echo ""

curl -X GET "http://localhost:5001/articles?page=2&limit=5" | jq '.'

echo ""
echo "==========================================="
echo ""

# GET articles filtrés par panierId
echo "🔵 Test: Récupération des articles d'un panier (panierId=1)"
echo "==========================================================="
echo ""

curl -X GET "http://localhost:5001/articles?panierId=1" | jq '.'

echo ""
echo "==========================================="
echo ""

# GET article by ID
echo "🔵 Test: Récupération d'un article par ID (ID=1)"
echo "================================================"
echo ""

curl -X GET http://localhost:5001/articles/1 | jq '.'

echo ""
echo "==========================================="
echo ""

# GET article by ID qui n'existe pas (doit retourner 404)
echo "🔵 Test: Récupération d'un article inexistant (ID=9999) - doit échouer"
echo "======================================================================"
echo ""

curl -X GET http://localhost:5001/articles/9999 | jq '.'

echo ""
echo "==========================================="
echo ""

# GET articles d'un panier spécifique via endpoint dédié
echo "🔵 Test: Récupération via endpoint /articles/panier/{panierId}"
echo "=============================================================="
echo ""

curl -X GET http://localhost:5001/articles/panier/1 | jq '.'

echo ""
echo "==========================================="
echo ""

# GET articles d'un panier avec pagination
echo "🔵 Test: Articles d'un panier avec pagination"
echo "============================================="
echo ""

curl -X GET "http://localhost:5001/articles/panier/1?page=1&limit=2" | jq '.'

echo ""
