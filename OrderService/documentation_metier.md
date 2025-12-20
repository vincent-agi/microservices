# Documentation Métier - API OrderService

## Vue d'ensemble

L'API OrderService est un microservice REST dédié à la gestion complète des commandes (orders) et des articles de commande (order items) dans le contexte d'une application e-commerce. Elle permet la création, la lecture, la modification et la suppression (CRUD) des commandes et des articles qui les composent.

## Domaine Métier

### Responsabilités
- **Gestion des commandes** : Création, modification, consultation et suppression des commandes
- **Gestion des articles de commande** : Ajout, modification et suppression d'articles dans les commandes
- **Suivi des statuts** : Gestion de l'état des commandes (CREATED, PAID, PREPARING, SHIPPED, DELIVERED, CANCELLED)
- **Association utilisateur** : Liaison des commandes avec les utilisateurs du système
- **Gestion des adresses** : Gestion des adresses de livraison et de facturation
- **Calcul des totaux** : Calcul des montants totaux des commandes et des lignes d'articles

### Entités Métier

#### Commande (Order)
Représente une commande passée par un utilisateur.

**Attributs** :
- `id` : Identifiant unique (auto-généré)
- `orderNumber` : Numéro de commande unique (généré automatiquement, format: ORD-YYYYMMDDHHMMSS-XXXX)
- `userId` : Identifiant de l'utilisateur qui a passé la commande (référence vers UserService)
- `shippingAddress` : Adresse de livraison (max 300 caractères)
- `billingAddress` : Adresse de facturation (max 300 caractères)
- `totalAmount` : Montant total de la commande (15 chiffres, 2 décimales)
- `status` : Statut de la commande (string: 'CREATED', 'PAID', 'PREPARING', 'SHIPPED', 'DELIVERED', 'CANCELLED')
- `createdAt` : Date et heure de création de la commande (timestamp automatique)
- `updatedAt` : Date et heure de dernière modification (timestamp automatique)

**Relations** :
- Une commande appartient à un utilisateur (relation avec UserService)
- Une commande contient plusieurs articles de commande (relation one-to-many avec OrderItem)

**Statuts possibles** :
- `CREATED` : Commande créée, en attente de paiement
- `PAID` : Commande payée
- `PREPARING` : Commande en cours de préparation
- `SHIPPED` : Commande expédiée
- `DELIVERED` : Commande livrée
- `CANCELLED` : Commande annulée

#### Article de Commande (OrderItem)
Représente un article (ligne de produit) dans une commande.

**Attributs** :
- `id` : Identifiant unique (auto-généré)
- `orderId` : Identifiant de la commande contenant cet article
- `productId` : Identifiant du produit (string pour permettre référence externe)
- `quantity` : Quantité du produit (minimum 1)
- `unitPrice` : Prix unitaire du produit (15 chiffres, 2 décimales)
- `totalLine` : Total de la ligne (calculé automatiquement : quantity × unitPrice)
- `createdAt` : Date et heure d'ajout de l'article (timestamp automatique)

**Relations** :
- Un article de commande appartient à une commande (relation many-to-one avec Order)
- Suppression en cascade : si une commande est supprimée, tous ses articles le sont aussi

**Règles de gestion** :
- Le `totalLine` est calculé automatiquement lors de la création et de la mise à jour
- La quantité doit être supérieure à 0
- Le prix unitaire doit être positif

## API REST Endpoints

### Base URL
```
http://localhost:8080
```

### Endpoints Commandes

#### 1. Créer une commande
**POST** `/api/orders`

Crée une nouvelle commande.

**Body (JSON)** :
```json
{
  "userId": 1,
  "shippingAddress": "123 Main St, City, Country",
  "billingAddress": "123 Main St, City, Country",
  "totalAmount": 99.99,
  "status": "CREATED",
  "orderItems": [
    {
      "productId": "PROD-001",
      "quantity": 2,
      "unitPrice": 49.99
    }
  ]
}
```

**Réponse (201 Created)** :
```json
{
  "data": {
    "id": 1,
    "orderNumber": "ORD-20251220103045-1234",
    "userId": 1,
    "shippingAddress": "123 Main St, City, Country",
    "billingAddress": "123 Main St, City, Country",
    "totalAmount": 99.99,
    "status": "CREATED",
    "createdAt": "2025-12-20T10:30:45.123",
    "updatedAt": "2025-12-20T10:30:45.123",
    "orderItems": [
      {
        "id": 1,
        "orderId": 1,
        "productId": "PROD-001",
        "quantity": 2,
        "unitPrice": 49.99,
        "totalLine": 99.98,
        "createdAt": "2025-12-20T10:30:45.123"
      }
    ]
  },
  "meta": {
    "timestamp": "1734691845123"
  }
}
```

**Règles métier** :
- Le userId est obligatoire et doit correspondre à un utilisateur existant
- Les adresses de livraison et de facturation sont obligatoires
- Le montant total est obligatoire
- Le statut par défaut est 'CREATED' s'il n'est pas spécifié
- Le numéro de commande est généré automatiquement
- Les articles de commande peuvent être inclus lors de la création (optionnel)

#### 2. Lister les commandes (avec pagination)
**GET** `/api/orders?page=1&limit=20&userId=1&status=CREATED`

Récupère la liste des commandes avec pagination et filtres optionnels.

**Query Parameters** :
- `page` : Numéro de page (par défaut : 1, minimum : 1)
- `limit` : Nombre d'éléments par page (par défaut : 20, minimum : 1, maximum : 100)
- `userId` : Filtre par utilisateur (optionnel)
- `status` : Filtre par statut (optionnel)

**Réponse (200 OK)** :
```json
{
  "data": [
    {
      "id": 1,
      "orderNumber": "ORD-20251220103045-1234",
      "userId": 1,
      "shippingAddress": "123 Main St, City, Country",
      "billingAddress": "123 Main St, City, Country",
      "totalAmount": 99.99,
      "status": "CREATED",
      "createdAt": "2025-12-20T10:30:45.123",
      "updatedAt": "2025-12-20T10:30:45.123"
    }
  ],
  "meta": {
    "timestamp": "1734691845123",
    "page": 1,
    "limit": 20,
    "total": 1,
    "totalPages": 1
  }
}
```

#### 3. Récupérer une commande par ID (avec articles)
**GET** `/api/orders/{id}`

Récupère les détails d'une commande spécifique avec tous ses articles.

**Réponse (200 OK)** :
```json
{
  "data": {
    "id": 1,
    "orderNumber": "ORD-20251220103045-1234",
    "userId": 1,
    "shippingAddress": "123 Main St, City, Country",
    "billingAddress": "123 Main St, City, Country",
    "totalAmount": 99.99,
    "status": "PAID",
    "createdAt": "2025-12-20T10:30:45.123",
    "updatedAt": "2025-12-20T11:00:00.000",
    "orderItems": [
      {
        "id": 1,
        "orderId": 1,
        "productId": "PROD-001",
        "quantity": 2,
        "unitPrice": 49.99,
        "totalLine": 99.98,
        "createdAt": "2025-12-20T10:30:45.123"
      }
    ]
  },
  "meta": {
    "timestamp": "1734691845123"
  }
}
```

**Erreur (404 Not Found)** :
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Order with ID 999 not found",
    "details": {
      "orderId": 999
    }
  }
}
```

#### 4. Mettre à jour une commande
**PUT** `/api/orders/{id}`

Met à jour les informations d'une commande existante.

**Body (JSON)** :
```json
{
  "shippingAddress": "456 New St, City, Country",
  "billingAddress": "456 New St, City, Country",
  "totalAmount": 149.99,
  "status": "PAID"
}
```

**Réponse (200 OK)** :
```json
{
  "data": {
    "id": 1,
    "orderNumber": "ORD-20251220103045-1234",
    "userId": 1,
    "shippingAddress": "456 New St, City, Country",
    "billingAddress": "456 New St, City, Country",
    "totalAmount": 149.99,
    "status": "PAID",
    "createdAt": "2025-12-20T10:30:45.123",
    "updatedAt": "2025-12-20T11:15:00.000"
  },
  "meta": {
    "timestamp": "1734695700000"
  }
}
```

**Règles métier** :
- Tous les champs sont optionnels
- Seuls les champs fournis sont mis à jour
- Le userId ne peut pas être modifié
- Le numéro de commande ne peut pas être modifié
- La date de mise à jour est automatiquement mise à jour

#### 5. Supprimer une commande
**DELETE** `/api/orders/{id}`

Supprime une commande et tous ses articles (cascade).

**Réponse (204 No Content)** :
Aucun contenu retourné en cas de succès.

**Règles métier** :
- La suppression est définitive
- Tous les articles de la commande sont supprimés automatiquement (CASCADE)

#### 6. Récupérer les commandes d'un utilisateur
**GET** `/api/orders/user/{userId}?page=1&limit=20`

Récupère toutes les commandes d'un utilisateur spécifique avec pagination.

**Query Parameters** :
- `page` : Numéro de page (par défaut : 1)
- `limit` : Nombre d'éléments par page (par défaut : 20, max : 100)

**Réponse (200 OK)** :
```json
{
  "data": [
    {
      "id": 1,
      "orderNumber": "ORD-20251220103045-1234",
      "userId": 1,
      "shippingAddress": "123 Main St, City, Country",
      "billingAddress": "123 Main St, City, Country",
      "totalAmount": 99.99,
      "status": "PAID",
      "createdAt": "2025-12-20T10:30:45.123",
      "updatedAt": "2025-12-20T11:00:00.000"
    }
  ],
  "meta": {
    "timestamp": "1734691845123",
    "page": 1,
    "limit": 20,
    "total": 1,
    "totalPages": 1
  }
}
```

### Endpoints Articles de Commande

#### 1. Créer un article de commande
**POST** `/api/order-items`

Ajoute un nouvel article dans une commande.

**Body (JSON)** :
```json
{
  "orderId": 1,
  "productId": "PROD-123",
  "quantity": 2,
  "unitPrice": 49.99
}
```

**Réponse (201 Created)** :
```json
{
  "data": {
    "id": 1,
    "orderId": 1,
    "productId": "PROD-123",
    "quantity": 2,
    "unitPrice": 49.99,
    "totalLine": 99.98,
    "createdAt": "2025-12-20T10:35:00.000"
  },
  "meta": {
    "timestamp": "1734692100000"
  }
}
```

**Règles métier** :
- La commande doit exister
- La quantité doit être supérieure à 0
- Le prix unitaire doit être positif
- Le totalLine est calculé automatiquement

#### 2. Lister les articles de commande (avec pagination)
**GET** `/api/order-items?page=1&limit=20&orderId=1`

Récupère la liste des articles de commande avec pagination et filtre optionnel.

**Query Parameters** :
- `page` : Numéro de page (par défaut : 1)
- `limit` : Nombre d'éléments par page (par défaut : 20, max : 100)
- `orderId` : Filtre par commande (optionnel)

**Réponse (200 OK)** :
```json
{
  "data": [
    {
      "id": 1,
      "orderId": 1,
      "productId": "PROD-123",
      "quantity": 2,
      "unitPrice": 49.99,
      "totalLine": 99.98,
      "createdAt": "2025-12-20T10:35:00.000"
    }
  ],
  "meta": {
    "timestamp": "1734692100000",
    "page": 1,
    "limit": 20,
    "total": 1,
    "totalPages": 1
  }
}
```

#### 3. Récupérer un article de commande par ID
**GET** `/api/order-items/{id}`

Récupère les détails d'un article de commande spécifique.

**Réponse (200 OK)** :
```json
{
  "data": {
    "id": 1,
    "orderId": 1,
    "productId": "PROD-123",
    "quantity": 2,
    "unitPrice": 49.99,
    "totalLine": 99.98,
    "createdAt": "2025-12-20T10:35:00.000"
  },
  "meta": {
    "timestamp": "1734692100000"
  }
}
```

#### 4. Mettre à jour un article de commande
**PUT** `/api/order-items/{id}`

Met à jour les informations d'un article de commande existant.

**Body (JSON)** :
```json
{
  "quantity": 5,
  "unitPrice": 44.99
}
```

**Réponse (200 OK)** :
```json
{
  "data": {
    "id": 1,
    "orderId": 1,
    "productId": "PROD-123",
    "quantity": 5,
    "unitPrice": 44.99,
    "totalLine": 224.95,
    "createdAt": "2025-12-20T10:35:00.000"
  },
  "meta": {
    "timestamp": "1734692400000"
  }
}
```

**Règles métier** :
- Tous les champs sont optionnels
- La quantité doit être supérieure à 0
- Le prix unitaire doit être positif
- Le totalLine est recalculé automatiquement

#### 5. Supprimer un article de commande
**DELETE** `/api/order-items/{id}`

Supprime un article d'une commande.

**Réponse (204 No Content)** :
Aucun contenu retourné en cas de succès.

#### 6. Récupérer les articles d'une commande
**GET** `/api/order-items/order/{orderId}?page=1&limit=20`

Récupère tous les articles d'une commande spécifique avec pagination.

**Query Parameters** :
- `page` : Numéro de page (par défaut : 1)
- `limit` : Nombre d'éléments par page (par défaut : 20, max : 100)

**Réponse (200 OK)** :
```json
{
  "data": [
    {
      "id": 1,
      "orderId": 1,
      "productId": "PROD-123",
      "quantity": 2,
      "unitPrice": 49.99,
      "totalLine": 99.98,
      "createdAt": "2025-12-20T10:35:00.000"
    }
  ],
  "meta": {
    "timestamp": "1734692100000",
    "page": 1,
    "limit": 20,
    "total": 1,
    "totalPages": 1
  }
}
```

### Endpoint de Santé

#### Health Check
**GET** `/api/orders/health`

Vérifie l'état de santé du service.

**Réponse (200 OK)** :
```json
{
  "status": "UP",
  "service": "OrderService"
}
```

## Gestion des Erreurs

Toutes les erreurs suivent le format standardisé défini dans `standardisation_api_rest.md` :

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Message d'erreur explicite",
    "details": {
      "field": "nom_du_champ"
    }
  }
}
```

### Codes d'erreur courants

| Code HTTP | Code Erreur | Description |
|-----------|-------------|-------------|
| 400 | BAD_REQUEST | Paramètres de requête invalides |
| 400 | VALIDATION_ERROR | Erreur de validation des données |
| 404 | NOT_FOUND | Ressource non trouvée (commande ou article) |
| 404 | ORDER_NOT_FOUND | Commande non trouvée |
| 500 | INTERNAL_SERVER_ERROR | Erreur interne du serveur |

## Cas d'Usage Métier

### 1. Création d'une commande depuis un panier
**Scénario** : Un utilisateur valide son panier et crée une commande

**Flux** :
1. L'utilisateur a un panier validé dans CartService
2. Le système récupère les informations du panier (articles, quantités, prix)
3. Le système crée une nouvelle commande avec le statut 'CREATED'
4. Les articles du panier sont convertis en articles de commande
5. Le numéro de commande unique est généré automatiquement
6. La commande est sauvegardée avec tous ses articles

### 2. Paiement d'une commande
**Scénario** : Un utilisateur paie une commande

**Flux** :
1. L'utilisateur effectue le paiement (via un service de paiement externe)
2. Le paiement est confirmé
3. Le système met à jour le statut de la commande à 'PAID'
4. Une notification peut être envoyée à l'utilisateur (via NotificationService)

### 3. Préparation et expédition
**Scénario** : Une commande est préparée et expédiée

**Flux** :
1. Le personnel de l'entrepôt prépare la commande
2. Le statut passe à 'PREPARING'
3. La commande est expédiée
4. Le statut passe à 'SHIPPED'
5. Un numéro de suivi peut être ajouté (extension future)

### 4. Livraison de la commande
**Scénario** : La commande est livrée au client

**Flux** :
1. Le transporteur livre la commande
2. Le statut passe à 'DELIVERED'
3. L'utilisateur peut confirmer la réception

### 5. Annulation d'une commande
**Scénario** : Un utilisateur annule sa commande

**Flux** :
1. L'utilisateur demande l'annulation
2. Le système vérifie que la commande peut être annulée (statut CREATED ou PAID)
3. Le statut passe à 'CANCELLED'
4. Un remboursement peut être initié si la commande était payée

### 6. Consultation de l'historique des commandes
**Scénario** : Un utilisateur consulte ses commandes passées

**Flux** :
1. L'utilisateur demande ses commandes via `/api/orders/user/{userId}`
2. Le système retourne toutes les commandes avec pagination
3. L'utilisateur peut voir les détails de chaque commande
4. L'utilisateur peut suivre l'état de ses commandes en cours

## Intégration avec d'autres microservices

### UserService
Le OrderService communique avec UserService pour :
- **Vérifier l'existence des utilisateurs** : Avant de créer une commande avec un userId
- **Récupérer les informations utilisateur** : Pour compléter les données de commande (nom, email, etc.)

**Communication** :
```
GET http://user-api:3000/users/{id}
```

### CartService
Lorsqu'un panier est validé (statut 'completed'), les données peuvent être transmises à OrderService pour créer une commande :
- Informations du panier (id, userId)
- Liste des articles avec quantités et prix
- Adresses de livraison et facturation

**Flux de conversion Panier → Commande** :
1. CartService récupère le panier complet avec articles
2. CartService appelle OrderService pour créer une commande
3. Les articles du panier deviennent des articles de commande
4. Le panier passe en statut 'completed'

**Communication** :
```
POST http://order-api:8080/api/orders
```

### NotificationService (intégration future)
Lors des changements de statut de commande, des notifications peuvent être envoyées :
- Commande créée
- Paiement confirmé
- Commande expédiée
- Commande livrée

## Base de Données

### Configuration
- **Type** : MySQL 8.0
- **Host** : order-db (Docker network)
- **Port** : 3306 (interne) / 3309 (externe)
- **Base** : order_database
- **Charset** : utf8mb4
- **Collation** : utf8mb4_0900_ai_ci

### Tables

#### Table `orders`
```sql
CREATE TABLE `orders` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_number` varchar(50) NOT NULL,
  `user_id` int NOT NULL,
  `shipping_address` varchar(300) NOT NULL,
  `billing_address` varchar(300) NOT NULL,
  `total_amount` decimal(15,2) NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'CREATED',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_number` (`order_number`),
  KEY `idx_orders_user_id` (`user_id`),
  KEY `idx_orders_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

#### Table `order_items`
```sql
CREATE TABLE `order_items` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL,
  `product_id` varchar(255) NOT NULL,
  `quantity` int NOT NULL,
  `unit_price` decimal(15,2) NOT NULL,
  `total_line` decimal(15,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_order_items_order_id` (`order_id`),
  KEY `idx_order_items_product_id` (`product_id`),
  CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
```

### Stratégie de données
- **Auto-incrémentation** : Les IDs sont générés automatiquement
- **Timestamps automatiques** : Gestion automatique des dates de création et mise à jour
- **Cascade deletion** : La suppression d'une commande supprime tous ses articles
- **Index** : Index sur user_id et status pour optimiser les recherches
- **Contraintes** : Le numéro de commande est unique

## Architecture Technique

### Structure du projet
```
OrderService/
├── src/
│   ├── main/
│   │   ├── java/com/example/orderservice/
│   │   │   ├── OrderServiceApplication.java    # Point d'entrée Spring Boot
│   │   │   ├── entity/
│   │   │   │   ├── Order.java                  # Entité Order
│   │   │   │   └── OrderItem.java              # Entité OrderItem
│   │   │   ├── repository/
│   │   │   │   ├── OrderRepository.java        # Repository Order
│   │   │   │   └── OrderItemRepository.java    # Repository OrderItem
│   │   │   ├── service/
│   │   │   │   ├── OrderService.java           # Logique métier Order
│   │   │   │   └── OrderItemService.java       # Logique métier OrderItem
│   │   │   ├── controller/
│   │   │   │   ├── OrderController.java        # Endpoints REST Order
│   │   │   │   └── OrderItemController.java    # Endpoints REST OrderItem
│   │   │   ├── dto/
│   │   │   │   ├── OrderDTO.java               # DTO Order
│   │   │   │   ├── CreateOrderDTO.java         # DTO création Order
│   │   │   │   ├── UpdateOrderDTO.java         # DTO mise à jour Order
│   │   │   │   ├── OrderItemDTO.java           # DTO OrderItem
│   │   │   │   ├── CreateOrderItemDTO.java     # DTO création OrderItem
│   │   │   │   └── UpdateOrderItemDTO.java     # DTO mise à jour OrderItem
│   │   │   └── util/
│   │   │       ├── ApiResponse.java            # Wrapper réponses
│   │   │       ├── ApiError.java               # Format erreurs
│   │   │       └── PaginatedResponse.java      # Réponses paginées
│   │   └── resources/
│   │       ├── application.properties          # Configuration Spring
│   │       └── schema.sql                      # Script SQL initialisation
│   └── test/
│       └── java/com/example/orderservice/
│           └── OrderServiceApplicationTests.java
├── pom.xml                                     # Dépendances Maven
├── .env                                        # Variables d'environnement
├── docker-compose.yml                          # Configuration Docker
├── Dockerfile.dev                              # Image Docker développement
└── test-api-*.sh                               # Scripts de test API
```

### Technologies utilisées
- **Spring Boot 3.3.0** : Framework Java pour le développement d'applications
- **Spring Data JPA** : ORM pour la gestion de la base de données
- **Hibernate** : Implémentation JPA
- **MySQL Connector/J** : Driver JDBC pour MySQL
- **Jakarta Validation** : Validation des données (JSR 380)
- **Spring Web** : Support REST API
- **Spring DevTools** : Hot reload en développement

### Patterns appliqués
- **MVC Pattern** : Séparation Controllers / Services / Repositories
- **Service Layer** : Logique métier isolée dans les services
- **Repository Pattern** : Abstraction de l'accès aux données via Spring Data JPA
- **DTO Pattern** : Transfert de données entre couches
- **Dependency Injection** : Injection des dépendances via Spring

## Conformité aux Standards

Cette API respecte les standards définis dans `standardisation_api_rest.md` :
- ✅ Endpoints orientés ressources avec pluriel (/api/orders, /api/order-items)
- ✅ Pas de verbes dans les URLs
- ✅ Format JSON avec camelCase
- ✅ Réponses uniformisées avec `data` et `meta`
- ✅ Codes HTTP appropriés (200, 201, 204, 400, 404, 500)
- ✅ Erreurs normalisées avec `error.code`, `error.message`, `error.details`
- ✅ Pagination avec `page` et `limit` (max 100 par page)
- ✅ Timestamp en millisecondes dans meta
- ✅ Documentation JavaDoc dans le code
- ✅ Validation des inputs avec Jakarta Validation

## Sécurité

### Protection des données
- Validation de tous les inputs utilisateur avec Jakarta Validation
- Vérification de l'existence des ressources avant modification
- Validation des types de données
- Prévention des injections SQL via JPA/Hibernate
- Utilisation de PreparedStatements via l'ORM

### Communication inter-services
- Timeout sur les appels aux autres services (configuration future)
- Gestion des erreurs de connexion
- Messages d'erreur explicites en cas de problème
- Isolation des bases de données par service

## Évolutions Futures

### Fonctionnalités prévues
- **Gestion des retours** : Possibilité de retourner une commande
- **Suivi de livraison** : Numéro de suivi et statut détaillé
- **Factures** : Génération automatique de factures PDF
- **Historique des statuts** : Traçabilité complète des changements de statut
- **Notifications** : Intégration avec NotificationService pour alertes email/SMS
- **Codes promo** : Application de réductions sur les commandes
- **Calcul automatique des frais de port** : Selon poids et destination
- **Multi-devises** : Support de plusieurs devises
- **Export des commandes** : Export CSV/Excel pour analyses

## Support et Contact

Pour toute question sur cette API :
- **Équipe** : Mohamed & Othman
- **Repository** : https://github.com/vincent-agi/microservices
- **Service** : OrderService (Spring Boot/Java)
