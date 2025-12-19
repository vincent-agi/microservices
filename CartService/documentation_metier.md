# Documentation Métier - API CartService

## Vue d'ensemble

L'API CartService est un microservice REST dédié à la gestion complète des paniers d'achat (carts) et des articles dans ces paniers. Elle permet la création, la lecture, la modification et la suppression (CRUD) des paniers et des articles qui les composent dans le contexte d'une application e-commerce.

## Domaine Métier

### Responsabilités
- **Gestion des paniers** : Création, modification, consultation et suppression des paniers d'achat
- **Gestion des articles** : Ajout, modification et suppression d'articles dans les paniers
- **Calcul des totaux** : Calcul automatique des lignes de prix et des totaux de panier
- **Association utilisateur** : Liaison des paniers avec les utilisateurs du système
- **Statut des paniers** : Gestion de l'état des paniers (actif, complété, abandonné)

### Entités Métier

#### Panier (Shopping Cart)
Représente un panier d'achat d'un utilisateur.

**Attributs** :
- `idPanier` : Identifiant unique (auto-généré)
- `dateCreation` : Date et heure de création du panier
- `dateModification` : Date et heure de dernière modification
- `status` : Statut du panier (string: 'active', 'completed', 'abandoned')
- `userId` : Identifiant de l'utilisateur propriétaire (référence vers UserService)

**Relations** :
- Un panier appartient à un utilisateur (relation avec UserService)
- Un panier contient plusieurs articles (relation one-to-many avec Article)

**Calculs automatiques** :
- Nombre total d'articles dans le panier
- Prix total du panier (somme des total_line de tous les articles)

#### Article (Cart Item)
Représente un article (ligne de produit) dans un panier d'achat.

**Attributs** :
- `idArticle` : Identifiant unique (auto-généré)
- `panierId` : Identifiant du panier contenant cet article
- `productId` : Identifiant du produit (string pour permettre référence externe)
- `quantity` : Quantité du produit
- `unitPrice` : Prix unitaire du produit
- `totalLine` : Total de la ligne (calculé automatiquement : quantity × unitPrice)
- `createdAt` : Date et heure d'ajout de l'article

**Relations** :
- Un article appartient à un panier (relation many-to-one avec Panier)
- Suppression en cascade : si un panier est supprimé, tous ses articles le sont aussi

**Règles de gestion** :
- Le `totalLine` est calculé automatiquement par la base de données
- La quantité doit être supérieure à 0
- Le prix unitaire ne peut pas être négatif

## API REST Endpoints

### Base URL
```
http://localhost:5001
```

### Endpoints Paniers

#### 1. Créer un panier
**POST** `/paniers`

Crée un nouveau panier d'achat.

**Body (JSON)** :
```json
{
  "userId": 1,
  "status": "active"
}
```

**Réponse (201 Created)** :
```json
{
  "data": {
    "idPanier": 1,
    "dateCreation": "2024-12-19T10:00:00.000Z",
    "dateModification": null,
    "status": "active",
    "userId": 1
  },
  "meta": {
    "timestamp": "1734602400000"
  }
}
```

**Règles métier** :
- Le userId est optionnel (panier anonyme possible)
- Si userId est fourni, l'utilisateur doit exister dans UserService
- Le statut par défaut est 'active'
- La date de création est automatiquement générée

#### 2. Lister les paniers (avec pagination)
**GET** `/paniers?page=1&limit=20&userId=1&status=active`

Récupère la liste des paniers avec pagination et filtres optionnels.

**Query Parameters** :
- `page` : Numéro de page (par défaut : 1)
- `limit` : Nombre d'éléments par page (par défaut : 20, max : 100)
- `userId` : Filtre par utilisateur (optionnel)
- `status` : Filtre par statut (optionnel)

**Réponse (200 OK)** :
```json
{
  "data": [
    {
      "idPanier": 1,
      "dateCreation": "2024-12-19T10:00:00.000Z",
      "dateModification": null,
      "status": "active",
      "userId": 1
    }
  ],
  "meta": {
    "timestamp": "1734602400000",
    "page": 1,
    "limit": 20,
    "total": 1,
    "totalPages": 1
  }
}
```

#### 3. Récupérer un panier par ID (avec articles)
**GET** `/paniers/{id}`

Récupère les détails d'un panier spécifique avec tous ses articles et les totaux.

**Réponse (200 OK)** :
```json
{
  "data": {
    "idPanier": 1,
    "dateCreation": "2024-12-19T10:00:00.000Z",
    "dateModification": "2024-12-19T10:15:00.000Z",
    "status": "active",
    "userId": 1,
    "articles": [
      {
        "idArticle": 1,
        "panierId": 1,
        "productId": "PROD-123",
        "quantity": 2,
        "unitPrice": 29.99,
        "totalLine": 59.98,
        "createdAt": "2024-12-19T10:05:00.000Z"
      }
    ],
    "totalQuantity": 2,
    "totalPrice": 59.98
  },
  "meta": {
    "timestamp": "1734602400000"
  }
}
```

**Erreur (404 Not Found)** :
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Panier with ID 999 not found",
    "details": {}
  }
}
```

#### 4. Mettre à jour un panier
**PUT** `/paniers/{id}`

Met à jour les informations d'un panier existant.

**Body (JSON)** :
```json
{
  "status": "completed",
  "userId": 1
}
```

**Réponse (200 OK)** :
```json
{
  "data": {
    "idPanier": 1,
    "dateCreation": "2024-12-19T10:00:00.000Z",
    "dateModification": "2024-12-19T11:00:00.000Z",
    "status": "completed",
    "userId": 1
  },
  "meta": {
    "timestamp": "1734606000000"
  }
}
```

**Règles métier** :
- Tous les champs sont optionnels
- Si userId est modifié, l'utilisateur doit exister dans UserService
- La date de modification est mise à jour automatiquement

#### 5. Supprimer un panier
**DELETE** `/paniers/{id}`

Supprime un panier et tous ses articles (cascade).

**Réponse (204 No Content)** :
Aucun contenu retourné en cas de succès.

**Règles métier** :
- La suppression est définitive
- Tous les articles du panier sont supprimés automatiquement (CASCADE)

#### 6. Récupérer les paniers d'un utilisateur
**GET** `/paniers/user/{userId}?page=1&limit=20`

Récupère tous les paniers d'un utilisateur spécifique avec pagination.

**Query Parameters** :
- `page` : Numéro de page (par défaut : 1)
- `limit` : Nombre d'éléments par page (par défaut : 20, max : 100)

**Réponse (200 OK)** :
```json
{
  "data": [
    {
      "idPanier": 1,
      "dateCreation": "2024-12-19T10:00:00.000Z",
      "dateModification": null,
      "status": "active",
      "userId": 1
    }
  ],
  "meta": {
    "timestamp": "1734602400000",
    "page": 1,
    "limit": 20,
    "total": 1,
    "totalPages": 1
  }
}
```

### Endpoints Articles

#### 1. Créer un article
**POST** `/articles`

Ajoute un nouvel article dans un panier.

**Body (JSON)** :
```json
{
  "panierId": 1,
  "productId": "PROD-123",
  "quantity": 2,
  "unitPrice": 29.99
}
```

**Réponse (201 Created)** :
```json
{
  "data": {
    "idArticle": 1,
    "panierId": 1,
    "productId": "PROD-123",
    "quantity": 2,
    "unitPrice": 29.99,
    "totalLine": 59.98,
    "createdAt": "2024-12-19T10:05:00.000Z"
  },
  "meta": {
    "timestamp": "1734602700000"
  }
}
```

**Règles métier** :
- Le panier doit exister
- La quantité doit être supérieure à 0
- Le prix unitaire ne peut pas être négatif
- Le totalLine est calculé automatiquement

#### 2. Lister les articles (avec pagination)
**GET** `/articles?page=1&limit=20&panierId=1`

Récupère la liste des articles avec pagination et filtre optionnel.

**Query Parameters** :
- `page` : Numéro de page (par défaut : 1)
- `limit` : Nombre d'éléments par page (par défaut : 20, max : 100)
- `panierId` : Filtre par panier (optionnel)

**Réponse (200 OK)** :
```json
{
  "data": [
    {
      "idArticle": 1,
      "panierId": 1,
      "productId": "PROD-123",
      "quantity": 2,
      "unitPrice": 29.99,
      "totalLine": 59.98,
      "createdAt": "2024-12-19T10:05:00.000Z"
    }
  ],
  "meta": {
    "timestamp": "1734602700000",
    "page": 1,
    "limit": 20,
    "total": 1,
    "totalPages": 1
  }
}
```

#### 3. Récupérer un article par ID
**GET** `/articles/{id}`

Récupère les détails d'un article spécifique.

**Réponse (200 OK)** :
```json
{
  "data": {
    "idArticle": 1,
    "panierId": 1,
    "productId": "PROD-123",
    "quantity": 2,
    "unitPrice": 29.99,
    "totalLine": 59.98,
    "createdAt": "2024-12-19T10:05:00.000Z"
  },
  "meta": {
    "timestamp": "1734602700000"
  }
}
```

#### 4. Mettre à jour un article
**PUT** `/articles/{id}`

Met à jour les informations d'un article existant.

**Body (JSON)** :
```json
{
  "quantity": 5,
  "unitPrice": 24.99
}
```

**Réponse (200 OK)** :
```json
{
  "data": {
    "idArticle": 1,
    "panierId": 1,
    "productId": "PROD-123",
    "quantity": 5,
    "unitPrice": 24.99,
    "totalLine": 124.95,
    "createdAt": "2024-12-19T10:05:00.000Z"
  },
  "meta": {
    "timestamp": "1734602800000"
  }
}
```

**Règles métier** :
- Tous les champs sont optionnels
- La quantité doit être supérieure à 0
- Le prix unitaire ne peut pas être négatif
- Le totalLine est recalculé automatiquement

#### 5. Supprimer un article
**DELETE** `/articles/{id}`

Supprime un article d'un panier.

**Réponse (204 No Content)** :
Aucun contenu retourné en cas de succès.

#### 6. Récupérer les articles d'un panier
**GET** `/articles/panier/{panierId}?page=1&limit=20`

Récupère tous les articles d'un panier spécifique avec pagination.

**Query Parameters** :
- `page` : Numéro de page (par défaut : 1)
- `limit` : Nombre d'éléments par page (par défaut : 20, max : 100)

**Réponse (200 OK)** :
```json
{
  "data": [
    {
      "idArticle": 1,
      "panierId": 1,
      "productId": "PROD-123",
      "quantity": 2,
      "unitPrice": 29.99,
      "totalLine": 59.98,
      "createdAt": "2024-12-19T10:05:00.000Z"
    }
  ],
  "meta": {
    "timestamp": "1734602700000",
    "page": 1,
    "limit": 20,
    "total": 1,
    "totalPages": 1
  }
}
```

### Endpoint de Santé

#### Health Check
**GET** `/health`

Vérifie l'état de santé du service.

**Réponse (200 OK)** :
```json
{
  "status": "healthy",
  "service": "CartService"
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
| 404 | NOT_FOUND | Ressource non trouvée (panier ou article) |
| 404 | USER_NOT_FOUND | Utilisateur non trouvé dans UserService |
| 500 | INTERNAL_SERVER_ERROR | Erreur interne du serveur |

## Cas d'Usage Métier

### 1. Création d'un panier pour un utilisateur connecté
**Scénario** : Un utilisateur se connecte et commence ses achats

**Flux** :
1. L'utilisateur s'authentifie via UserService
2. Le système crée un nouveau panier avec l'userId
3. Le panier est créé avec le statut 'active'
4. L'utilisateur peut commencer à ajouter des articles

### 2. Ajout d'articles au panier
**Scénario** : Un utilisateur ajoute des produits à son panier

**Flux** :
1. L'utilisateur sélectionne un produit et une quantité
2. Le système crée un article avec le productId, quantity et unitPrice
3. Le totalLine est calculé automatiquement
4. L'article est ajouté au panier
5. Les totaux du panier sont mis à jour

### 3. Modification de la quantité d'un article
**Scénario** : Un utilisateur modifie la quantité d'un article dans son panier

**Flux** :
1. L'utilisateur change la quantité
2. Le système met à jour l'article
3. Le totalLine est recalculé automatiquement
4. Les totaux du panier sont mis à jour

### 4. Validation du panier (passage en commande)
**Scénario** : Un utilisateur valide son panier pour passer commande

**Flux** :
1. L'utilisateur valide son panier
2. Le système récupère le panier avec tous ses articles et totaux
3. Le statut du panier passe à 'completed'
4. Les données sont transmises à OrderService pour créer une commande
5. Un nouveau panier 'active' peut être créé pour de futurs achats

### 5. Abandon de panier
**Scénario** : Un utilisateur abandonne son panier

**Flux** :
1. L'utilisateur quitte sans valider
2. Le système peut marquer le panier comme 'abandoned'
3. Le panier reste en base pour analyse ou relance marketing

### 6. Consultation de l'historique des paniers
**Scénario** : Un utilisateur consulte ses anciens paniers

**Flux** :
1. L'utilisateur demande ses paniers via `/paniers/user/{userId}`
2. Le système retourne tous les paniers (actifs, complétés, abandonnés)
3. L'utilisateur peut voir le détail de chaque panier avec ses articles

## Intégration avec d'autres microservices

### UserService
Le CartService communique avec UserService pour :
- **Vérifier l'existence des utilisateurs** : Avant d'associer un panier à un userId
- **Validation des propriétaires** : S'assurer que les utilisateurs existent

**Communication** :
```
GET http://user-api:3000/users/{id}
```

### OrderService (intégration future)
Lorsqu'un panier est validé (statut 'completed'), les données peuvent être transmises à OrderService pour créer une commande :
- Informations du panier (id, userId)
- Liste des articles avec quantités et prix
- Totaux calculés

## Base de Données

### Configuration
- **Type** : MySQL
- **Host** : db (Docker network)
- **Port** : 3306 (interne) / 3307 (externe)
- **Base** : cart_db

### Tables

#### Table `panier`
```sql
CREATE TABLE `panier` (
  `id_panier` int NOT NULL AUTO_INCREMENT,
  `date_creation` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `date_modification` timestamp NULL DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  PRIMARY KEY (`id_panier`)
);
```

#### Table `article`
```sql
CREATE TABLE `article` (
  `id_article` int NOT NULL AUTO_INCREMENT,
  `panier_id` int NOT NULL,
  `product_id` varchar(255) NOT NULL,
  `quantity` int NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `total_line` decimal(10,2) GENERATED ALWAYS AS ((`quantity` * `unit_price`)) STORED,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_article`),
  KEY `fk_panier` (`panier_id`),
  CONSTRAINT `fk_panier` FOREIGN KEY (`panier_id`) REFERENCES `panier` (`id_panier`) ON DELETE CASCADE
);
```

### Stratégie de données
- **Auto-incrémentation** : Les IDs sont générés automatiquement
- **Timestamps automatiques** : Gestion automatique des dates
- **Cascade deletion** : La suppression d'un panier supprime tous ses articles
- **Colonnes calculées** : Le totalLine est calculé automatiquement par MySQL

## Architecture Technique

### Structure du projet
```
CartService/
├── app/
│   ├── main.py                 # Point d'entrée Flask
│   ├── config/
│   │   ├── __init__.py
│   │   └── database.py         # Configuration base de données
│   ├── models/
│   │   ├── __init__.py
│   │   ├── panier.py          # Entité Panier
│   │   └── article.py         # Entité Article
│   ├── services/
│   │   ├── __init__.py
│   │   ├── panier_service.py  # Logique métier Panier
│   │   └── article_service.py # Logique métier Article
│   ├── controllers/
│   │   ├── __init__.py
│   │   ├── panier_controller.py  # Endpoints REST Panier
│   │   └── article_controller.py # Endpoints REST Article
│   └── utils/
│       ├── __init__.py
│       ├── responses.py        # Helpers réponses standardisées
│       ├── validation.py       # Helpers validation
│       └── user_service.py     # Communication UserService
├── requirements.txt
├── .env
└── docker-compose.yml
```

### Technologies utilisées
- **Flask** : Framework web Python
- **SQLAlchemy** : ORM pour la gestion de la base de données
- **MySQL Connector** : Driver MySQL pour Python
- **Marshmallow** : Sérialisation/désérialisation (si nécessaire)
- **Requests** : Communication HTTP avec UserService

### Patterns appliqués
- **MVC Pattern** : Séparation Models / Controllers
- **Service Layer** : Logique métier isolée dans les services
- **Repository Pattern** : Abstraction de l'accès aux données via SQLAlchemy
- **Dependency Injection** : Injection de sessions de base de données

## Conformité aux Standards

Cette API respecte les standards définis dans `standardisation_api_rest.md` :
- ✅ Endpoints orientés ressources avec pluriel (/paniers, /articles)
- ✅ Pas de verbes dans les URLs
- ✅ Format JSON avec camelCase
- ✅ Réponses uniformisées avec `data` et `meta`
- ✅ Codes HTTP appropriés (200, 201, 204, 400, 404, 500)
- ✅ Erreurs normalisées avec `error.code`, `error.message`, `error.details`
- ✅ Pagination avec `page` et `limit`
- ✅ Timestamp en millisecondes dans meta
- ✅ Documentation PyDoc dans le code

## Sécurité

### Protection des données
- Validation de tous les inputs utilisateur
- Vérification de l'existence des ressources avant modification
- Validation des types de données
- Prévention des injections SQL via SQLAlchemy ORM

### Communication inter-services
- Timeout sur les appels au UserService (5 secondes)
- Gestion des erreurs de connexion
- Messages d'erreur explicites en cas de problème

## Évolutions Futures

### Fonctionnalités prévues
- **Gestion du stock** : Vérification de la disponibilité des produits
- **Prix dynamiques** : Récupération des prix depuis un ProductService
- **Promotions** : Application de codes promo et réductions
- **Paniers partagés** : Possibilité de partager un panier entre utilisateurs
- **Sauvegarde automatique** : Persistance des paniers anonymes
- **Notifications** : Alertes sur paniers abandonnés
- **Analytics** : Statistiques sur les comportements d'achat

## Support et Contact

Pour toute question sur cette API :
- **Équipe** : Imane & Jonathan
- **Repository** : https://github.com/vincent-agi/microservices
- **Service** : CartService (Flask/Python)
