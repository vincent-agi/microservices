#!/bin/bash

# Script pour tester la suppression d'un utilisateur (DELETE /users/:id)
# Usage: ./test-api-delete-user.sh [USER_ID]
# Exemple: ./test-api-delete-user.sh 2

USER_ID=${1:-2}

echo "🔵 Test: Vérification de l'utilisateur avant suppression (ID=$USER_ID)"
echo "====================================================================="
echo ""

# Afficher l'utilisateur avant suppression
curl -X GET http://localhost:3000/users/$USER_ID | jq '.'

echo ""
echo "==========================================="
echo ""

# Suppression de l'utilisateur
echo "🔴 Test: Suppression de l'utilisateur (ID=$USER_ID)"
echo "==================================================="
echo ""

curl -X DELETE http://localhost:3000/users/$USER_ID \
  -w "\nHTTP Status: %{http_code}\n"

echo ""
echo "==========================================="
echo ""

# Vérifier que l'utilisateur n'existe plus
echo "🔵 Test: Vérification après suppression (doit retourner 404)"
echo "==========================================================="
echo ""

curl -X GET http://localhost:3000/users/$USER_ID | jq '.'

echo ""
echo "==========================================="
echo ""

# Tentative de suppression d'un utilisateur déjà supprimé
echo "🔵 Test: Tentative de suppression d'un utilisateur inexistant (doit échouer)"
echo "==========================================================================="
echo ""

curl -X DELETE http://localhost:3000/users/$USER_ID \
  -w "\nHTTP Status: %{http_code}\n" | jq '.'

echo ""
