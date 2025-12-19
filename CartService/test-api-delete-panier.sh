#!/bin/bash

# Script pour tester la suppression d'un panier (DELETE /paniers/:id)
# Usage: ./test-api-delete-panier.sh [PANIER_ID]
# Exemple: ./test-api-delete-panier.sh 2

PANIER_ID=${1:-2}

echo "🔵 Test: Vérification du panier avant suppression (ID=$PANIER_ID)"
echo "================================================================="
echo ""

# Afficher le panier avant suppression
curl -X GET http://localhost:5001/paniers/$PANIER_ID

echo ""
echo "==========================================="
echo ""

# Suppression du panier
echo "🔴 Test: Suppression du panier (ID=$PANIER_ID)"
echo "=============================================="
echo ""

curl -X DELETE http://localhost:5001/paniers/$PANIER_ID \
  -w "\nHTTP Status: %{http_code}\n"

echo ""
echo "==========================================="
echo ""

# Vérifier que le panier n'existe plus
echo "🔵 Test: Vérification après suppression (doit retourner 404)"
echo "==========================================================="
echo ""

curl -X GET http://localhost:5001/paniers/$PANIER_ID

echo ""
echo "==========================================="
echo ""

# Tentative de suppression d'un panier déjà supprimé
echo "🔵 Test: Tentative de suppression d'un panier inexistant (doit échouer)"
echo "======================================================================"
echo ""

curl -X DELETE http://localhost:5001/paniers/$PANIER_ID \
  -w "\nHTTP Status: %{http_code}\n"

echo ""
echo "==========================================="
echo ""

# Note sur la cascade
echo "Note: La suppression d'un panier supprime automatiquement tous ses articles (CASCADE)"
echo ""
