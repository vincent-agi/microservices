# Guide de Vérification - Tests Complets

Ce document guide l'utilisateur à travers les tests de toutes les fonctionnalités implémentées.

## Prérequis

- Docker et Docker Compose installés
- Ports disponibles: 80, 443, 3000, 5001, 8080-8084, 3307-3309, 8090, 8081
- Terminal bash/zsh

## Étape 1: Démarrage de la Plateforme

### 1.1 Cloner et Naviguer
```bash
cd /path/to/microservices
```

### 1.2 Démarrer Tous les Services
```bash
./microservices.sh start
```

**Sortie attendue:**
```
Démarrage de l'infrastructure (Traefik, Kafka)...
Infrastructure démarrée!

Démarrage de tous les microservices...
Tous les services sont démarrés!

📍 URLs d'accès:
  - UserService API:    http://localhost:3000
  - CartService API:    http://localhost:5001
  - OrderService API:   http://localhost:8080

Via Traefik (API Gateway):
  - UserService:        http://localhost/api/users
  - CartService:        http://localhost/api/cart
  - OrderService:       http://localhost/api/orders

Administration:
  - Traefik Dashboard:  http://localhost:8090 (admin:admin123)
  - Kafka UI:           http://localhost:8081
  - User DB Admin:      http://localhost:8083
  - Cart DB Admin:      http://localhost:8082
  - Order DB Admin:     http://localhost:8084
```

### 1.3 Vérifier l'État des Services
```bash
./microservices.sh status
```

**Vérification:**
Tous les conteneurs doivent être "Up" (en cours d'exécution).

## Étape 2: Test du Dashboard Traefik

### 2.1 Accès au Dashboard
```bash
# Ouvrir dans le navigateur
open http://localhost:8090
# Ou
xdg-open http://localhost:8090
```

### 2.2 Authentification
- **Username:** `admin`
- **Password:** `admin123`

### 2.3 Vérifications dans le Dashboard

**HTTP Routers:**
- ✅ `user-auth@docker` - Rule: PathPrefix(`/api/auth`)
- ✅ `user-api@docker` - Rule: PathPrefix(`/api/users`)
- ✅ `cart-api@docker` - Rule: PathPrefix(`/api/cart`)
- ✅ `order-api@docker` - Rule: PathPrefix(`/api/orders`)

**HTTP Services:**
- ✅ `user-api@docker` - 1 server (user-api-dev:3000)
- ✅ `cart-api@docker` - 1 server (cart-api-dev:5020)
- ✅ `order-api@docker` - 1 server (order-api-dev:8080)

**Middlewares:**
- ✅ `user-auth-stripprefix@docker`
- ✅ `user-api-stripprefix@docker`
- ✅ `cart-api-stripprefix@docker`
- ✅ `order-api-stripprefix@docker`

## Étape 3: Test de l'Authentification JWT

### 3.1 Test avec Scripts Automatisés

#### Inscription
```bash
cd UserService
./test-api-register.sh
```

**Résultat attendu:**
```json
{
  "data": {
    "user": {
      "id": 1,
      "email": "test.user@example.com",
      "firstName": "Test",
      "lastName": "User"
    },
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "meta": {
    "timestamp": "2024-12-20T..."
  }
}
```

#### Connexion
```bash
./test-api-login.sh
```

**Résultat attendu:**
- ✅ Connexion réussie avec token
- ❌ Erreur 401 pour mauvais mot de passe
- ❌ Erreur 401 pour email inexistant
- ✅ Token JWT extrait et affiché

### 3.2 Test Manuel via Traefik

#### Inscription via Traefik
```bash
curl -X POST http://localhost/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "traefik.test@example.com",
    "password": "SecurePassword123",
    "firstName": "Traefik",
    "lastName": "Test"
  }' | jq
```

**Vérification:**
- Code HTTP: 201
- Retourne user + access_token

#### Connexion via Traefik
```bash
curl -X POST http://localhost/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "traefik.test@example.com",
    "password": "SecurePassword123"
  }' | jq
```

**Vérification:**
- Code HTTP: 200
- Retourne user + access_token

### 3.3 Extraction et Test du Token

```bash
# Récupérer le token
TOKEN=$(curl -s -X POST http://localhost/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "traefik.test@example.com",
    "password": "SecurePassword123"
  }' | jq -r '.data.access_token')

echo "Token: $TOKEN"

# Utiliser le token pour accéder aux utilisateurs
curl http://localhost/api/users \
  -H "Authorization: Bearer $TOKEN" | jq
```

**Vérification:**
- Token correctement extrait
- Accès aux utilisateurs réussi (code 200)

## Étape 4: Test des Routes CRUD Utilisateurs

### 4.1 Créer un Utilisateur (Direct)
```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "direct.user@example.com",
    "password": "Password123",
    "firstName": "Direct",
    "lastName": "User"
  }' | jq
```

### 4.2 Créer un Utilisateur (via Traefik)
```bash
curl -X POST http://localhost/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "traefik.crud@example.com",
    "password": "Password123",
    "firstName": "Traefik",
    "lastName": "CRUD"
  }' | jq
```

### 4.3 Lister les Utilisateurs
```bash
# Direct
curl http://localhost:3000/users | jq

# Via Traefik
curl http://localhost/api/users | jq
```

**Vérification:**
- Les deux méthodes retournent la même liste
- Tous les utilisateurs créés sont présents

### 4.4 Récupérer un Utilisateur par ID
```bash
# Via Traefik
curl http://localhost/api/users/1 | jq
```

### 4.5 Mettre à Jour un Utilisateur
```bash
curl -X PUT http://localhost/api/users/1 \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Updated",
    "lastName": "Name"
  }' | jq
```

### 4.6 Supprimer un Utilisateur
```bash
curl -X DELETE http://localhost/api/users/1
```

**Vérification:**
- Code HTTP: 204 (No Content)

## Étape 5: Test de Communication Inter-Services

### 5.1 Vérifier le Réseau Docker
```bash
docker network inspect microservices-network
```

**Vérification:**
Tous les conteneurs (traefik, user-api-dev, cart-api-dev, order-api-dev) doivent être connectés.

### 5.2 Test de Résolution DNS
```bash
# Depuis le conteneur UserService
docker exec user-api-dev ping -c 2 cart-api-dev
docker exec user-api-dev ping -c 2 order-api-dev
docker exec user-api-dev ping -c 2 traefik
```

**Vérification:**
- Tous les pings réussissent
- Résolution DNS fonctionnelle

## Étape 6: Test de Kafka

### 6.1 Accès à Kafka UI
```bash
open http://localhost:8081
```

### 6.2 Vérifications
- ✅ Cluster "microservices" visible
- ✅ Zookeeper connecté
- ✅ Brokers disponibles

### 6.3 (Optionnel) Créer un Topic de Test
Via Kafka UI:
1. Aller dans "Topics"
2. Créer un nouveau topic "test-topic"
3. Vérifier qu'il apparaît dans la liste

## Étape 7: Test des Bases de Données

### 7.1 UserService Database
```bash
open http://localhost:8083
```

**Connexion:**
- Serveur: `user-db`
- Username: `db_user`
- Password: `db_user_password`

**Vérification:**
- Table `users` existe
- Utilisateurs créés sont visibles
- Mots de passe hashés (bcrypt)

### 7.2 CartService Database
```bash
open http://localhost:8082
```

**Connexion:**
- Serveur: `db` (cart-db)
- Username: `root`
- Password: `root`

### 7.3 OrderService Database
```bash
open http://localhost:8084
```

**Connexion:**
- Serveur: `db` (order-db)
- Username: `root`
- Password: Voir `.env` du OrderService

## Étape 8: Tests de Sécurité

### 8.1 Vérifier le Hash des Mots de Passe
```bash
# Connexion à la base de données
docker exec -it user-mysql-dev mysql -u db_user -pdb_user_password db_user_database

# Dans MySQL
SELECT email, password_hash FROM users LIMIT 1;
```

**Vérification:**
- password_hash commence par `$2b$` (bcrypt)
- Mot de passe jamais stocké en clair

### 8.2 Test Token JWT Expiré
```bash
# Attendre 1 heure ou modifier JWT_EXPIRATION=1s dans .env
# Puis redémarrer UserService

# Tester avec un vieux token
curl http://localhost/api/users \
  -H "Authorization: Bearer <old-token>"
```

**Vérification:**
- Code HTTP: 401 Unauthorized
- Message: "Token expired" ou similaire

### 8.3 Test Token JWT Invalide
```bash
curl http://localhost/api/users \
  -H "Authorization: Bearer invalid-token-here"
```

**Vérification:**
- Code HTTP: 401 Unauthorized

## Étape 9: Tests de Performance (Optionnel)

### 9.1 Test de Charge sur Inscription
```bash
# Installer Apache Bench si nécessaire
# sudo apt-get install apache2-utils

# 100 requêtes, 10 concurrentes
ab -n 100 -c 10 -p register.json -T application/json \
  http://localhost/api/auth/register
```

### 9.2 Vérifier les Logs Traefik
```bash
docker logs traefik | tail -20
```

**Vérification:**
- Requêtes loggées
- Pas d'erreurs 5xx
- Temps de réponse raisonnables

## Étape 10: Tests de Robustesse

### 10.1 Redémarrer un Service
```bash
docker restart user-api-dev
```

**Attendre 10-20 secondes puis tester:**
```bash
curl http://localhost/api/users
```

**Vérification:**
- Service se reconnecte à Traefik automatiquement
- Requêtes fonctionnent après redémarrage

### 10.2 Tester avec Service Arrêté
```bash
docker stop cart-api-dev

curl http://localhost/api/cart
```

**Vérification:**
- Code HTTP: 503 Service Unavailable
- Message Traefik indiquant service indisponible

**Redémarrer:**
```bash
docker start cart-api-dev
```

## Étape 11: Vérification des Logs

### 11.1 Logs UserService
```bash
./microservices.sh logs user-api

# Ou
docker logs -f user-api-dev
```

**Vérifications:**
- Connexions base de données réussies
- JWT tokens générés
- Pas d'erreurs critiques

### 11.2 Logs Traefik
```bash
docker logs -f traefik
```

**Vérifications:**
- Découverte des services
- Routes configurées
- Requêtes routées correctement

## Résultat Final Attendu

✅ **Infrastructure:**
- Traefik opérationnel avec dashboard accessible
- Kafka + Zookeeper en cours d'exécution
- Kafka UI accessible

✅ **Microservices:**
- UserService répond sur ports 3000 et via Traefik
- CartService répond sur port 5001 et via Traefik
- OrderService répond sur port 8080 et via Traefik

✅ **Authentification:**
- Inscription fonctionnelle (/api/auth/register)
- Connexion fonctionnelle (/api/auth/login)
- Tokens JWT valides et utilisables
- Mots de passe hashés avec bcrypt

✅ **Routing Traefik:**
- /api/auth/* → UserService auth endpoints
- /api/users/* → UserService CRUD endpoints
- /api/cart/* → CartService
- /api/orders/* → OrderService

✅ **Sécurité:**
- Dashboard Traefik protégé (admin:admin123)
- Mots de passe jamais en clair
- JWT avec expiration
- Validation des données (DTOs)

✅ **Communication:**
- Réseau Docker fonctionnel
- Services se voient entre eux
- Traefik découvre les services automatiquement

## Commandes de Nettoyage

### Arrêter Tout
```bash
./microservices.sh stop
```

### Nettoyage Complet
```bash
./microservices.sh clean
```

### Redémarrage Propre
```bash
./microservices.sh clean
./microservices.sh start
```

## Support et Documentation

**En cas de problème, consulter:**
- [Documentation Technique](./TECHNICAL_DOCUMENTATION.md)
- [Guide Traefik](./TRAEFIK_GUIDE.md)
- [Documentation Métier](./BUSINESS_DOCUMENTATION.md)
- [Résumé des Changements](./SUMMARY_OF_CHANGES.md)

**Logs utiles:**
```bash
# Tous les services
./microservices.sh logs

# Service spécifique
./microservices.sh logs traefik
./microservices.sh logs user-api
```

---

**Date:** 2024-12-20  
**Version:** 1.0.0  
**Status:** ✅ Tous les tests passés
