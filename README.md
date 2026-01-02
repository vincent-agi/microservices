# Projet Microservices - Architecture Distribuée E-Commerce

## 🚀 Quick Start

### Cloner le projet

> Attention il vous faut une clé SSH sur votre compte github pour clone/push/pull

```bash
git clone git@github.com:vincent-agi/microservices.git
cd microservices
```

### Lancer la plateforme

```bash
# Démarrage de l'infrastructure et des microservices
./microservices.sh start
```

La plateforme démarre dans l'ordre suivant:
1. Infrastructure (Traefik, Kafka, Zookeeper)
2. Microservices (User, Cart, Order)

## 📋 Équipes et Attribution des Services

### Services Métier
- **UserService** (NestJS/TypeScript) : Mouhcine & Vincent
- **CartService** (Flask/Python) : Imane & Jonathan  
- **OrderService** (Spring Boot/Java) : Mohamed & Othman

### Services Transverses
- **API Gateway (Traefik)** : Vincent
- **NotificationService** : Vincent

## 🏗️ Architecture Technique

### Vue d'Ensemble

L'architecture adopte le pattern microservices avec :
- **Isolation des services** : Chaque service possède sa propre base de données
- **API Gateway centralisé** : Traefik comme point d'entrée unique
- **Communication REST** : APIs REST standardisées entre services
- **Authentification JWT** : Sécurisation avec JSON Web Tokens
- **Message Broker** : Kafka pour la communication asynchrone
- **Conteneurisation** : Docker et Docker Compose

### 🌐 Ports et Accès

#### Via Traefik (API Gateway) - Recommandé
- **UserService API** : [http://localhost/api/users](http://localhost/api/users)
- **CartService API** : [http://localhost/api/cart](http://localhost/api/cart)
- **OrderService API** : [http://localhost/api/orders](http://localhost/api/orders)

#### Accès Direct (Développement)
- **UserService** : [http://localhost:3000](http://localhost:3000)
- **CartService** : [http://localhost:5001](http://localhost:5001)
- **OrderService** : [http://localhost:8080](http://localhost:8080)

#### Infrastructure et Administration
- **Traefik Dashboard** : [http://localhost:8090](http://localhost:8090) (admin:admin123)
- **Kafka UI** : [http://localhost:8081](http://localhost:8081)

### 📊 Tableau Récapitulatif des Accès

| Service | Type | URL | Port | Identifiants |
|---------|------|-----|------|--------------|
| **UserService API** | API Gateway | http://localhost/api/users | 80 | JWT Token requis |
| **UserService API** | Accès direct | http://localhost:3000 | 3000 | JWT Token requis |
| **UserService Auth** | API Gateway | http://localhost/api/auth | 80 | - |
| **UserService DB** | MySQL | localhost:3308 | 3308 | db_user / db_user_password |
| **UserService Admin** | phpMyAdmin | http://localhost:8083 | 8083 | db_user / db_user_password |
| **CartService API** | API Gateway | http://localhost/api/cart | 80 | - |
| **CartService API** | Accès direct | http://localhost:5001 | 5001 | - |
| **CartService DB** | MySQL | localhost:3307 | 3307 | root / root |
| **CartService Admin** | phpMyAdmin | http://localhost:8082 | 8082 | root / root |
| **OrderService API** | API Gateway | http://localhost/api/orders | 80 | - |
| **OrderService API** | Accès direct | http://localhost:8080 | 8080 | - |
| **OrderService DB** | MySQL | localhost:3309 | 3309 | order_db_user / order_password |
| **OrderService Admin** | phpMyAdmin | http://localhost:8084 | 8084 | order_db_user / order_password |
| **Traefik Dashboard** | Dashboard | http://localhost:8090 | 8090 | admin / admin123 |
| **Kafka UI** | Dashboard | http://localhost:8081 | 8081 | - |

#### Bases de Données MySQL

Chaque microservice possède sa propre base de données MySQL isolée :

**UserService Database:**
- **Port** : 3308
- **Host** : localhost (externe) / user-db (interne Docker)
- **Base de données** : db_user_database
- **Utilisateur** : db_user
- **Mot de passe** : db_user_password
- **Root password** : db_user_password

**CartService Database:**
- **Port** : 3307
- **Host** : localhost (externe) / db (interne Docker)
- **Base de données** : cart_db
- **Utilisateur** : root
- **Mot de passe** : root

**OrderService Database:**
- **Port** : 3309
- **Host** : localhost (externe) / order-db (interne Docker)
- **Base de données** : order_database
- **Utilisateur** : order_db_user
- **Mot de passe** : order_password
- **Root password** : order_password

#### Interface d'Administration (phpMyAdmin)

Chaque service dispose de sa propre instance phpMyAdmin pour gérer facilement sa base de données :

**UserService phpMyAdmin:**
- **URL** : [http://localhost:8083](http://localhost:8083)
- **Serveur** : user-db
- **Utilisateur** : db_user (ou root)
- **Mot de passe** : db_user_password

**CartService phpMyAdmin:**
- **URL** : [http://localhost:8082](http://localhost:8082)
- **Serveur** : db
- **Utilisateur** : root
- **Mot de passe** : root

**OrderService phpMyAdmin:**
- **URL** : [http://localhost:8084](http://localhost:8084)
- **Serveur** : order-db
- **Utilisateur** : order_db_user (ou root)
- **Mot de passe** : order_password

## 🔐 Authentification JWT

### Inscription
```bash
curl -X POST http://localhost/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePassword123",
    "firstName": "John",
    "lastName": "Doe"
  }'
```

### Connexion
```bash
curl -X POST http://localhost/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePassword123"
  }'
```

### Utilisation du Token
```bash
curl http://localhost/api/users \
  -H "Authorization: Bearer <votre-token-jwt>"
```

### Scripts de Test
```bash
# Tester l'inscription
./UserService/test-api-register.sh

# Tester la connexion
./UserService/test-api-login.sh
```

## 📦 Déploiement

### Prérequis
- Docker et Docker Compose installés
- Ports nécessaires disponibles : 80, 443, 3000, 5001, 8080-8084, 3307-3309, 8090

### Déploiement Centralisé (Recommandé)

#### Commandes Disponibles
```bash
# Démarrage de tous les services (infrastructure + microservices)
./microservices.sh start

# Arrêt de tous les services
./microservices.sh stop

# Redémarrage complet
./microservices.sh restart

# État des services
./microservices.sh status

# Logs de tous les services
./microservices.sh logs

# Logs d'un service spécifique
./microservices.sh logs user-api

# Reconstruction des images
./microservices.sh build

# Nettoyage complet (conteneurs + volumes)
./microservices.sh clean
```

### Communication Inter-Services

#### Via Traefik (Clients Externes)
Les clients externes accèdent aux services via Traefik sur le port 80:
```bash
# Exemple avec curl
curl http://localhost/api/users
curl http://localhost/api/cart
curl http://localhost/api/orders
```

#### Communication Interne (Entre Microservices)
Les services communiquent entre eux via le réseau Docker `microservices-network`:

```javascript
// Depuis CartService, appeler UserService
const response = await fetch('http://user-api-dev:3000/users/123', {
  headers: {
    'Authorization': `Bearer ${jwtToken}`
  }
});

// Depuis OrderService, appeler CartService
const cartResponse = await fetch('http://cart-api-dev:5020/cart/user/123');
```

**Noms des conteneurs:**
- **UserService** : `user-api-dev:3000`
- **CartService** : `cart-api-dev:5020`
- **OrderService** : `order-api-dev:8080`

### Déploiement Individuel (Développement)

```bash
# UserService uniquement
cd UserService && docker-compose up -d

# CartService uniquement
cd CartService && docker-compose up -d

# OrderService uniquement
cd OrderService && docker-compose up -d
```

**Note:** L'infrastructure (Traefik, Kafka) doit être démarrée avec `docker-compose up -d` depuis la racine.

## ⚙️ Configuration

### Variables d'Environnement

#### UserService (.env)
```env
# Base de données
DB_HOST=user-db
DB_USER=db_user
DB_PASSWORD=db_user_password
DB_NAME=db_user_database
NODE_ENV=development

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRATION=1h

# Bcrypt Configuration
BCRYPT_SALT_ROUNDS=10
```

**Connexion MySQL directe:**
```bash
mysql -h 127.0.0.1 -P 3308 -u db_user -pdb_user_password db_user_database
```

#### CartService (.env)
```env
# Base de données
DB_HOST=db
DB_USER=root
DB_PASSWORD=root
DB_NAME=cart_db
FLASK_ENV=development
```

**Connexion MySQL directe:**
```bash
mysql -h 127.0.0.1 -P 3307 -u root -proot cart_db
```

#### OrderService (.env)
```env
# Base de données
DB_HOST=order-db
DB_USER=order_db_user
DB_PASSWORD=order_password
DB_NAME=order_database
SPRING_PROFILES_ACTIVE=dev
```

**Connexion MySQL directe:**
```bash
mysql -h 127.0.0.1 -P 3309 -u order_db_user -porder_password order_database
```

### Réseau et Communication
- **Réseau partagé** : `microservices-network` (external bridge)
- **Isolation des données** : Base de données dédiée par service
- **Routage centralisé** : Traefik gère le routage HTTP
- **Communication interne** : Services communiquent via noms Docker

## 🎯 Fonctionnalités Implémentées

### UserService
- ✅ Gestion des utilisateurs (CRUD)
- ✅ Authentification JWT (register/login)
- ✅ Hash sécurisé des mots de passe (bcrypt)
- ✅ Validation des données (DTOs)
- ✅ Profils utilisateurs

### CartService  
- Gestion du panier d'achat
- Ajout/suppression d'articles
- Calcul des totaux

### OrderService
- Création et suivi des commandes
- Gestion des statuts
- Historique des commandes

### API Gateway (Traefik)
- ✅ Routage des requêtes HTTP
- ✅ Dashboard d'administration
- ✅ Découverte automatique des services
- ✅ Load balancing
- ✅ Monitoring en temps réel

### Infrastructure
- ✅ Kafka + Zookeeper (message broker)
- ✅ Kafka UI (administration)
- ✅ MySQL par service
- ✅ phpMyAdmin par service

### Kafka Topics (Communication Asynchrone)

Les topics Kafka suivants sont pré-configurés et automatiquement créés au démarrage:

#### Topics Order Service
- **order.created** - Émis lors de la création d'une nouvelle commande
- **order.updated** - Émis lors de la mise à jour du statut d'une commande
- **order.cancelled** - Émis lors de l'annulation d'une commande

#### Topics Payment
- **payment.pending** - Émis lors du démarrage d'un paiement
- **payment.completed** - Émis lors de la réussite d'un paiement
- **payment.failed** - Émis lors de l'échec d'un paiement

#### Topics Cart Service
- **cart.item.added** - Émis lors de l'ajout d'un article au panier
- **cart.item.removed** - Émis lors de la suppression d'un article du panier
- **cart.cleared** - Émis lors de la vidange du panier

#### Topics User Service
- **user.registered** - Émis lors de l'inscription d'un nouvel utilisateur
- **user.updated** - Émis lors de la mise à jour d'un profil utilisateur

**Configuration:**
- Partitions: 3 par topic (pour la scalabilité)
- Replication Factor: 1 (développement)
- Access Kafka UI: [http://localhost:8081](http://localhost:8081)

## 📖 Documentation

### Documentation Complète
- **[Documentation Technique](./docs/TECHNICAL_DOCUMENTATION.md)** - Architecture, choix techniques, JWT
- **[Documentation Métier](./docs/BUSINESS_DOCUMENTATION.md)** - Cas d'usage, règles métier, workflows
- **[Guide Traefik](./docs/TRAEFIK_GUIDE.md)** - Configuration, routage, dashboard

### Documentation par Service
- **[UserService](./UserService/README.md)** - API, endpoints, tests
- **[CartService](./CartService/README.md)** - API, endpoints, tests
- **[OrderService](./OrderService/README.md)** - API, endpoints, tests

### Standards
- **[Standardisation API REST](./standardisation_api_rest.md)** - Conventions REST à suivre

## 🧪 Tests

### UserService

**Scripts de test fournis:**
```bash
# Tests CRUD utilisateurs
./UserService/test-api-create-user.sh
./UserService/test-api-read-users.sh
./UserService/test-api-update-user.sh
./UserService/test-api-delete-user.sh

# Tests authentification
./UserService/test-api-register.sh
./UserService/test-api-login.sh

# Lancer tous les tests
cd UserService && ./run-all-tests.sh
```

### CartService et OrderService
Voir les README respectifs de chaque service.

## 🔧 Dépannage

### Vérifier l'état des services
```bash
./microservices.sh status
docker ps
```

### Consulter les logs
```bash
# Logs d'un service
docker logs -f user-api-dev
docker logs -f traefik

# Via le script
./microservices.sh logs user-api
```

### Dashboard Traefik
Accédez au dashboard pour voir l'état des routes et services:
- URL: http://localhost:8090
- Identifiants: admin / admin123

### Problèmes de réseau
```bash
# Vérifier le réseau Docker
docker network inspect microservices-network

# Recréer le réseau si nécessaire
docker network rm microservices-network
docker network create microservices-network
```

### Nettoyer et redémarrer
```bash
# Nettoyage complet
./microservices.sh clean

# Redémarrage propre
./microservices.sh start
```

## 🏗️ Architecture Réseau Docker

### Exemple de Communication Inter-Services

```javascript
// Depuis UserService, appeler CartService
const cartResponse = await fetch('http://cart-api:5020/api/cart/user/123');

// Depuis CartService, appeler OrderService  
const orderResponse = await fetch('http://order-api:8080/api/orders');
```

## Structure des Fichiers de Configuration

```
microservices/
├── docker-compose.yml          # Orchestration principale
├── microservices.sh           # Script de gestion
├── Makefile                   # Alternative Make
├── UserService/
│   ├── docker-compose.yml     # Config individuelle
│   └── .env                   # Variables d'environnement
├── CartService/
│   └── docker-compose.yml     # Config individuelle
│   └── .env                   # Variables d'environnement
└── OrderService/
    ├── docker-compose.yml     # Config individuelle
    └── .env                   # Variables d'environnement
```

## Problème de cache Docker

Si vous rencontrez des problèmes de build ou de dépendances, vous pouvez nettoyer le cache Docker avec la commande suivante :
```bash
docker system prune -a
```

## Planning

[Roadmap](ROADMAP.md)

## Notes Techniques

### Bonnes Pratiques Appliquées
- **Single Responsibility** : Un micoservice = un groupe de responsabilités métier = une base de données
- **Database per Service** : Isolation des données (ne pas créer une autre pasde données en plus pour votre microservice)
- **Documenatation** : Documenter ce que vous faites. C'est très important.
- **Respecter les standards** : [standardisation_api_rest](./standardisation_api_rest.md)

**Je vous encourage très fortement à mettre en place dès le début un logger dans vos microservices**

## 🏗️ Architecture Réseau Docker

### Schéma de Communication

```
┌─────────────────────────────────────────────────────────┐
│                    Client Externe                        │
└───────────────────────┬─────────────────────────────────┘
                        │ HTTP (Port 80)
                        ▼
┌─────────────────────────────────────────────────────────┐
│              Traefik API Gateway (Port 8090)             │
│  • Routage: /api/users → UserService                    │
│  • Routage: /api/cart → CartService                     │
│  • Routage: /api/orders → OrderService                  │
└───────┬─────────────┬─────────────┬─────────────────────┘
        │             │             │
        │             │             │  Réseau: microservices-network
        ▼             ▼             ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ UserService  │ │ CartService  │ │ OrderService │
│  Port: 3000  │ │  Port: 5020  │ │  Port: 8080  │
└──────┬───────┘ └──────┬───────┘ └──────┬───────┘
       │                │                │
       ▼                ▼                ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│   MySQL      │ │   MySQL      │ │   MySQL      │
│ User DB:3308 │ │ Cart DB:3307 │ │Order DB:3309 │
└──────────────┘ └──────────────┘ └──────────────┘

Infrastructure:
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  Zookeeper   │ │    Kafka     │ │  Kafka UI    │
│  Port: 2181  │ │  Port: 9092  │ │  Port: 8081  │
└──────────────┘ └──────────────┘ └──────────────┘
```

### Exemple de Communication Inter-Services

```javascript
// Client externe -> Traefik -> UserService
// POST http://localhost/api/users/../auth/register

// CartService -> UserService (vérification utilisateur)
const userResponse = await fetch('http://user-api-dev:3000/users/123', {
  headers: { 'Authorization': `Bearer ${token}` }
});

// OrderService -> CartService (récupération panier)
const cartResponse = await fetch('http://cart-api-dev:5020/cart/user/123');
```

## 📁 Structure des Fichiers

```
microservices/
├── docker-compose.yml              # Infrastructure (Traefik, Kafka, etc.)
├── microservices.sh               # Script de gestion centralisé
├── docs/                          # Documentation complète
│   ├── TECHNICAL_DOCUMENTATION.md
│   ├── BUSINESS_DOCUMENTATION.md
│   └── TRAEFIK_GUIDE.md
├── UserService/
│   ├── docker-compose.yml         # Config UserService + DB
│   ├── .env                       # Variables d'environnement
│   ├── app/src/
│   │   ├── auth/                  # Module authentification
│   │   │   ├── auth.module.ts
│   │   │   ├── auth.service.ts
│   │   │   ├── auth.controller.ts
│   │   │   ├── jwt.strategy.ts
│   │   │   └── jwt-auth.guard.ts
│   │   └── dto/
│   │       ├── register.dto.ts
│   │       └── login.dto.ts
│   └── test-api-*.sh              # Scripts de test
├── CartService/
│   ├── docker-compose.yml         # Config CartService + DB
│   └── .env
└── OrderService/
    ├── docker-compose.yml         # Config OrderService + DB
    └── .env
```

## 🛡️ Sécurité

### Mesures Implémentées

**Authentification:**
- ✅ JWT avec signature cryptographique
- ✅ Tokens avec expiration (1h)
- ✅ Hash des mots de passe (bcrypt, 10 rounds)
- ✅ Validation stricte des données (class-validator)

**Infrastructure:**
- ✅ Traefik dashboard protégé par Basic Auth
- ✅ Réseau Docker isolé
- ✅ Bases de données non exposées publiquement

**À faire en production:**
- [ ] Changer JWT_SECRET pour une valeur forte
- [ ] HTTPS avec certificats SSL (Let's Encrypt)
- [ ] Rate limiting sur endpoints sensibles
- [ ] Augmenter rounds bcrypt (12-14)
- [ ] Implémenter refresh tokens
- [ ] Logs d'audit

## 🚦 Problèmes Courants

### Port déjà utilisé
```bash
# Trouver le processus utilisant le port 80
sudo lsof -i :80

# Ou changer le port dans docker-compose.yml
ports:
  - "8000:80"  # Au lieu de "80:80"
```

### Problème de cache Docker
```bash
docker system prune -a
./microservices.sh start
```

### Connexion aux bases de données

#### Impossible de se connecter à phpMyAdmin

**Vérifier que les conteneurs sont démarrés:**
```bash
docker ps | grep phpmyadmin
docker ps | grep mysql
```

**Vérifier les logs phpMyAdmin:**
```bash
docker logs user-phpmyadmin
docker logs cart-phpmyadmin
docker logs order-phpmyadmin
```

#### Accès direct aux bases de données MySQL

**UserService Database:**
```bash
# Via MySQL client
mysql -h 127.0.0.1 -P 3308 -u db_user -pdb_user_password db_user_database

# Via Docker exec
docker exec -it user-mysql-dev mysql -u db_user -pdb_user_password db_user_database
```

**CartService Database:**
```bash
# Via MySQL client
mysql -h 127.0.0.1 -P 3307 -u root -proot cart_db

# Via Docker exec
docker exec -it cart-mysql-dev mysql -u root -proot cart_db
```

**OrderService Database:**
```bash
# Via MySQL client
mysql -h 127.0.0.1 -P 3309 -u order_db_user -porder_password order_database

# Via Docker exec
docker exec -it order-mysql-dev mysql -u order_db_user -porder_password order_database
```

### Réseau non trouvé
```bash
# Le réseau est créé au premier docker-compose up
cd /path/to/microservices
docker-compose up -d

# Ensuite démarrer les services
./microservices.sh start
```

## 📞 Support

Pour toute question ou problème:
1. Consultez la [Documentation Technique](./docs/TECHNICAL_DOCUMENTATION.md)
2. Vérifiez les logs: `./microservices.sh logs [service]`
3. Consultez le [Guide Traefik](./docs/TRAEFIK_GUIDE.md) pour les problèmes de routage

## 📄 Licence

Ce projet est privé et propriétaire.
