# Projet Microservices - Architecture Distribuée

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

### Technologies Utilisées

| Service | Framework | Base de Données | Port |
|---------|-----------|----------------|------|
| UserService | NestJS (TypeScript) | MySQL | 3000 |
| CartService | Flask (Python) | MySQL | 5001 |
| OrderService | Spring Boot (Java) | MySQL | 8080 |

### Ports et Accès

#### APIs
- **UserService** : http://localhost:3000
- **CartService** : http://localhost:5001  
- **OrderService** : http://localhost:8080

#### Bases de Données MySQL
- **User DB** : Port 3308
- **Cart DB** : Port 3307
- **Order DB** : Port 3309

#### Interface d'Administration (phpMyAdmin)
- **User DB Admin** : http://localhost:8083
- **Cart DB Admin** : http://localhost:8082
- **Order DB Admin** : http://localhost:8084

## Déploiement

### Prérequis
- Docker et Docker Compose installés
- Ports 3000, 5001, 8080-8084, 3307-3309 disponibles

### Déploiement Centralisé (Recommandé)

Le projet inclut un système de déploiement centralisé permettant de gérer tous les microservices depuis la racine.

#### Lancement Rapide

Ceux sur windows/Macbook/linux

```bash
# Depuis la racine du projet
docker-compose up -d --build
```

Ceux sur macbook et linux (commande enrichie)
```bash
# Depuis la racine du projet
./microservices.sh start
```

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

#### Alternative avec Docker Compose
```bash
# Démarrage
docker-compose up -d

# Arrêt
docker-compose down

# Logs
docker-compose logs -f
```

#### Alternative avec Makefile
```bash
# Afficher l'aide
make help

# Démarrage
make start

# Arrêt
make stop

# État des services
make status

# Logs spécifiques
make user-logs
make cart-logs
make order-logs
```

### Communication Inter-Services

Tous les services sont connectés au réseau Docker `microservices-network`, permettant la communication directe entre services :

- **UserService** accessible via : `http://user-api:3000`
- **CartService** accessible via : `http://cart-api:5000` (interne)  
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

### Réseau Partagé
Tous les microservices utilisent le réseau Docker `microservices-network` qui permet :
- **Communication directe** entre les services via leurs noms de conteneurs
- **Isolation** du trafic interne des microservices
- **Sécurité** avec la séparation du réseau externe

### Exemple de Communication Inter-Services
```javascript
// Depuis UserService, appeler CartService
const cartResponse = await fetch('http://cart-api:5000/api/cart/user/123');

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

## Planning

**Jalon 1** : 30/11/2025 -> L'architecture Docker doit être prête.

**Jalon 2** : 07/12/2025 -> Toutes les équipes doivent etre en mesure de lancer son microservice et de travailler dessus.

**Jalon 3** : 14/12/2025 -> Toutes les équipes doivent avoir défini et implémenté le schema de leur base de données (aidez vous de phpmyadmin)

**Jalon 4** : 21/12/2025 -> Chaque microservice doit être terminé + documentation.

**Jalon 5** : 28/12/2025 -> Tous les microservices doivent fonctionner ensemble + comportement valider par les équipes (en commun) + documentation générale du projet.

**Jalon 6** : 04/01/2026 -> Présentation finie (slides) + document des justifications + architecture.

**Deadline fixée** : 15/01/2026 -> Présentation finale.

## Notes Techniques

### Bonnes Pratiques Appliquées
- **Single Responsibility** : Un service = une responsabilité métier
- **Database per Service** : Isolation des données (ne pas créer une autre pasde données en plus pour votre microservice)
- **Documenatation** : Documenter ce que vous faites. C'est très important.

**Je vous encourage très fortement à mettre en place dès le début un logger dans vos microservices**
