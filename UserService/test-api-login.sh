#!/bin/bash

# Script pour tester la connexion d'un utilisateur (POST /auth/login)
# Usage: ./test-api-login.sh

echo "🔵 Test: Connexion d'un utilisateur"
echo "==========================================="
echo ""

# Connexion avec des identifiants valides
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test.user@example.com",
    "password": "SecurePassword123"
  }'

echo ""
echo "==========================================="
echo ""

# Test avec un mot de passe incorrect (doit retourner une erreur 401)
echo "🔵 Test: Tentative de connexion avec un mot de passe incorrect (doit échouer)"
echo "============================================================================="
echo ""

curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test.user@example.com",
    "password": "WrongPassword123"
  }'

echo ""
echo "==========================================="
echo ""

# Test avec un email inexistant (doit retourner une erreur 401)
echo "🔵 Test: Tentative de connexion avec un email inexistant (doit échouer)"
echo "======================================================================"
echo ""

curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "nonexistent@example.com",
    "password": "SomePassword123"
  }'

echo ""
echo "==========================================="
echo ""

# Test de connexion et sauvegarde du token JWT
echo "🔵 Test: Connexion et extraction du token JWT"
echo "============================================="
echo ""

TOKEN=$(curl -s -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test.user@example.com",
    "password": "SecurePassword123"
  }' | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

echo "Token JWT obtenu: $TOKEN"
echo ""

if [ -n "$TOKEN" ]; then
  echo "✅ Token JWT récupéré avec succès!"
  echo "Vous pouvez maintenant l'utiliser pour accéder aux routes protégées:"
  echo "  curl -H \"Authorization: Bearer $TOKEN\" http://localhost:3000/protected-route"
else
  echo "❌ Échec de la récupération du token JWT"
fi

echo ""
