#!/bin/bash

# Script pour tester la suppression d'un article (DELETE /articles/:id)
# Usage: ./test-api-delete-article.sh [ARTICLE_ID]
# Exemple: ./test-api-delete-article.sh 2

ARTICLE_ID=${1:-2}

echo "🔵 Test: Vérification de l'article avant suppression (ID=$ARTICLE_ID)"
echo "===================================================================="
echo ""

# Afficher l'article avant suppression
curl -X GET http://localhost:5001/articles/$ARTICLE_ID

echo ""
echo "==========================================="
echo ""

# Suppression de l'article
echo "🔴 Test: Suppression de l'article (ID=$ARTICLE_ID)"
echo "=================================================="
echo ""

curl -X DELETE http://localhost:5001/articles/$ARTICLE_ID \
  -w "\nHTTP Status: %{http_code}\n"

echo ""
echo "==========================================="
echo ""

# Vérifier que l'article n'existe plus
echo "🔵 Test: Vérification après suppression (doit retourner 404)"
echo "==========================================================="
echo ""

curl -X GET http://localhost:5001/articles/$ARTICLE_ID

echo ""
echo "==========================================="
echo ""

# Tentative de suppression d'un article déjà supprimé
echo "🔵 Test: Tentative de suppression d'un article inexistant (doit échouer)"
echo "========================================================================"
echo ""

curl -X DELETE http://localhost:5001/articles/$ARTICLE_ID \
  -w "\nHTTP Status: %{http_code}\n"

echo ""
