# Projet Microservices - Architecture Distribuée

## Quick start

### Cloner projet

> Attention il vous faut une clé SSH sur votre compte github pour clone/push/pull

```bash
git clone git@github.com:vincent-agi/microservices.git
```

### Launch it

```
cd microservices
```

```bash
# Démarrage de tous les services
./microservices.sh start
```

## Équipes et Attribution des Services

### Services Métier
- **UserService** (NestJS/TypeScript) : Mouhcine & Vincent
- **CartService** (Flask/Python) : Imane & Jonathan  
- **OrderService** (Spring Boot/Java) : Mohamed & Othman

### Services Transverses
- **API Gateway** : Vincent
- **NotificationService** : Vincent

## Architecture Technique

### Vue d'Ensemble
L'architecture adopte le pattern microservices avec :
- **Isolation des services** : Chaque service possède sa propre base de données
- **Communication asynchrone** : Messages entre services via API REST. Respecter les convention REST. (voir checlist sur le drive)
- **Gateway centralisé** : Point d'entrée unique pour les clients
- **Conteneurisation** : Déploiement via Docker et Docker Compose

### Ports et Accès

#### APIs
- **UserService** : [http://localhost:3000](http://localhost:3000)
- **CartService** : [http://localhost:5001](http://localhost:5001)
- **OrderService** : [http://localhost:8080](http://localhost:8080)

#### Bases de Données MySQL
- **User DB** : Port 3308
- **Cart DB** : Port 3307
- **Order DB** : Port 3309

#### Interface d'Administration (phpMyAdmin)
- **User DB Admin** : [http://localhost:8083](http://localhost:8083)
- **Cart DB Admin** : [http://localhost:8082](http://localhost:8082)
- **Order DB Admin** : [http://localhost:8084](http://localhost:8084)

### Message Queue

- **Kafka** : [http://localhost:8081](http://localhost:8081)

## Déploiement

> TODO

### Prérequis
- Docker et Docker Compose installés
- Ports 3000, 5001, 8080-8084, 3307-3309 disponibles

### Déploiement Centralisé (Recommandé)

Le projet inclut un système de déploiement centralisé permettant de gérer tous les microservices depuis la racine.

#### Commandes Disponibles
```bash
# Démarrage de tous les services
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

Tous les services sont connectés au réseau Docker `microservices-network`, permettant la communication directe entre services :

- **UserService** accessible via : `http://user-api:3000`
- **CartService** accessible via : `http://cart-api:5020`
- **OrderService** accessible via : `http://order-api:8080`

### Déploiement Individuel (Pour Développement)

#### Démarrage Individuel
```bash
# UserService
cd UserService && docker-compose up -d

# CartService  
cd CartService && docker-compose up -d

# OrderService
cd OrderService && docker-compose up -d
```

### Arrêt des Services
```bash
# Arrêt centralisé
./microservices.sh stop

# Arrêt individuel
cd [ServiceName] && docker-compose down
```

## Configuration

### Variables d'Environnement
Chaque service utilise un fichier `.env` pour sa configuration :

#### UserService (.env)
```env
DB_USER=user_db_user
DB_PASSWORD=user_password
DB_NAME=user_database
DB_HOST=user-db
NODE_ENV=development
```

#### OrderService (.env)
```env
DB_USER=order_db_user
DB_PASSWORD=order_password
DB_NAME=order_database
DB_HOST=order-db
SPRING_PROFILES_ACTIVE=dev
```

### Réseau et Communication
- **Réseau partagé** : `microservices-network` (bridge)
- **Isolation des données** : Base de données dédiée par service
- **Communication interne** : Les services communiquent via leurs noms Docker
- **Ports externes** : Exposés pour l'accès depuis l'hôte

## Fonctionnalités Prévues

### UserService
- Gestion des utilisateurs (CRUD)
- Authentification et autorisation
- Profils utilisateurs

### CartService  
- Gestion du panier d'achat
- Ajout/suppression d'articles
- Calcul des totaux

### OrderService
- Création et suivi des commandes
- Gestion des statuts
- Historique des commandes

### API Gateway
- Routage des requêtes
- Authentification centralisée
- Rate limiting

### NotificationService
- Message queue

## Architecture Réseau Docker

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

**Je vous encourage très fortement à mettre en place dès le début un logger dans vos microservices**
