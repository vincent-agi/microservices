#!/bin/bash

# Script pour tester la mise à jour d'un utilisateur (PUT /users/:id)
# Usage: ./test-api-update-user.sh [USER_ID]
# Exemple: ./test-api-update-user.sh 1

USER_ID=${1:-1}

echo "🔵 Test: Mise à jour partielle d'un utilisateur (ID=$USER_ID)"
echo "============================================================="
echo ""

# Update partiel - modification du prénom et nom
curl -X PUT http://localhost:3000/users/$USER_ID \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Jean",
    "lastName": "Dupont"
  }'

echo ""
echo "==========================================="
echo ""

# Update de l'email
echo "🔵 Test: Mise à jour de l'email"
echo "==============================="
echo ""

curl -X PUT http://localhost:3000/users/$USER_ID \
  -H "Content-Type: application/json" \
  -d '{
    "email": "jean.dupont@example.com"
  }'

echo ""
echo "==========================================="
echo ""

# Update du numéro de téléphone
echo "🔵 Test: Mise à jour du téléphone"
echo "================================="
echo ""

curl -X PUT http://localhost:3000/users/$USER_ID \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+33698765432"
  }'

echo ""
echo "==========================================="
echo ""

# Update du statut isActive
echo "🔵 Test: Désactivation de l'utilisateur"
echo "======================================="
echo ""

curl -X PUT http://localhost:3000/users/$USER_ID \
  -H "Content-Type: application/json" \
  -d '{
    "isActive": false
  }'

echo ""
echo "==========================================="
echo ""

# Réactivation de l'utilisateur
echo "🔵 Test: Réactivation de l'utilisateur"
echo "======================================"
echo ""

curl -X PUT http://localhost:3000/users/$USER_ID \
  -H "Content-Type: application/json" \
  -d '{
    "isActive": true
  }'

echo ""
echo "==========================================="
echo ""

# Update du mot de passe
echo "🔵 Test: Mise à jour du mot de passe"
echo "===================================="
echo ""

curl -X PUT http://localhost:3000/users/$USER_ID \
  -H "Content-Type: application/json" \
  -d '{
    "password": "NewSecurePassword456"
  }'

echo ""
