#!/bin/bash

# Script pour tester la lecture des paniers (GET /paniers et GET /paniers/:id)
# Usage: ./test-api-read-paniers.sh

echo "🔵 Test: Récupération de tous les paniers (avec pagination par défaut)"
echo "======================================================================="
echo ""

# GET all paniers (page 1, limit 20 par défaut)
curl -X GET http://localhost:5001/paniers

echo ""
echo "==========================================="
echo ""

# GET all paniers avec pagination personnalisée
echo "🔵 Test: Récupération avec pagination personnalisée (page 1, limit 5)"
echo "===================================================================="
echo ""

curl -X GET "http://localhost:5001/paniers?page=1&limit=5"

echo ""
echo "==========================================="
echo ""

# GET all paniers - page 2
echo "🔵 Test: Récupération de la page 2"
echo "================================="
echo ""

curl -X GET "http://localhost:5001/paniers?page=2&limit=5"

echo ""
echo "==========================================="
echo ""

# GET paniers filtrés par userId
echo "🔵 Test: Récupération des paniers d'un utilisateur (userId=1)"
echo "============================================================="
echo ""

curl -X GET "http://localhost:5001/paniers?userId=1"

echo ""
echo "==========================================="
echo ""

# GET paniers filtrés par status
echo "🔵 Test: Récupération des paniers avec status 'active'"
echo "======================================================"
echo ""

curl -X GET "http://localhost:5001/paniers?status=active"

echo ""
echo "==========================================="
echo ""

# GET panier by ID avec articles
echo "🔵 Test: Récupération d'un panier par ID avec articles (ID=1)"
echo "============================================================="
echo ""

curl -X GET http://localhost:5001/paniers/1

echo ""
echo "==========================================="
echo ""

# GET panier by ID qui n'existe pas (doit retourner 404)
echo "🔵 Test: Récupération d'un panier inexistant (ID=9999) - doit échouer"
echo "====================================================================="
echo ""

curl -X GET http://localhost:5001/paniers/9999

echo ""
echo "==========================================="
echo ""

# GET paniers d'un utilisateur spécifique
echo "🔵 Test: Récupération via endpoint /paniers/user/{userId}"
echo "========================================================="
echo ""

curl -X GET http://localhost:5001/paniers/user/1

echo ""
