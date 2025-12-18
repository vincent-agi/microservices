# Documentation Métier - API UserService

## Vue d'ensemble

L'API UserService est un microservice REST dédié à la gestion complète des utilisateurs de l'application. Elle permet la création, la lecture, la modification et la suppression (CRUD) des comptes utilisateurs avec des fonctionnalités de gestion des rôles.

## Domaine Métier

### Responsabilités
- **Gestion des utilisateurs** : Création, modification, consultation et suppression des comptes utilisateurs
- **Authentification** : Stockage sécurisé des mots de passe avec hashage bcrypt
- **Gestion des rôles** : Association d'utilisateurs à des rôles (relation many-to-many)
- **Statut des utilisateurs** : Gestion de l'état actif/inactif des comptes

### Entités Métier

#### User (Utilisateur)
Représente un utilisateur du système avec ses informations personnelles et d'authentification.

**Attributs** :
- `id` : Identifiant unique (auto-généré)
- `email` : Adresse email unique (obligatoire, utilisée pour l'authentification)
- `passwordHash` : Mot de passe hashé avec bcrypt (obligatoire)
- `firstName` : Prénom (optionnel)
- `lastName` : Nom de famille (optionnel)
- `phone` : Numéro de téléphone (optionnel)
- `isActive` : Statut actif/inactif du compte (par défaut : actif)
- `createdAt` : Date de création du compte
- `updatedAt` : Date de dernière modification
- `deletedAt` : Date de suppression (soft delete)

**Relations** :
- Un utilisateur peut avoir plusieurs rôles (relation many-to-many via user_roles)

#### Role (Rôle)
Représente un rôle attribuable aux utilisateurs pour gérer les permissions.

**Attributs** :
- `id` : Identifiant unique (auto-généré)
- `name` : Nom du rôle (unique, obligatoire)
- `description` : Description du rôle (optionnel)
- `createdAt` : Date de création
- `updatedAt` : Date de dernière modification

**Relations** :
- Un rôle peut être attribué à plusieurs utilisateurs (relation many-to-many via user_roles)

## API REST Endpoints

### Base URL
```
http://localhost:3000
```

### Endpoints Disponibles

#### 1. Créer un utilisateur
**POST** `/users`

Crée un nouveau compte utilisateur avec les informations fournies.

**Body (JSON)** :
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123",
  "firstName": "Jean",
  "lastName": "Dupont",
  "phone": "+33 6 12 34 56 78"
}
```

**Réponse (201 Created)** :
```json
{
  "data": {
    "id": 1,
    "email": "user@example.com",
    "firstName": "Jean",
    "lastName": "Dupont",
    "phone": "+33 6 12 34 56 78",
    "isActive": true,
    "createdAt": "2024-12-18T20:00:00.000Z",
    "updatedAt": "2024-12-18T20:00:00.000Z",
    "roles": []
  },
  "meta": {
    "timestamp": "1702929600000"
  }
}
```

**Règles métier** :
- L'email doit être unique dans le système
- Le mot de passe doit contenir au moins 8 caractères
- Le compte est créé avec le statut actif par défaut

#### 2. Lister les utilisateurs (avec pagination)
**GET** `/users?page=1&limit=20`

Récupère la liste des utilisateurs avec pagination.

**Query Parameters** :
- `page` : Numéro de page (par défaut : 1)
- `limit` : Nombre d'éléments par page (par défaut : 20, max : 100)

**Réponse (200 OK)** :
```json
{
  "data": [
    {
      "id": 1,
      "email": "user@example.com",
      "firstName": "Jean",
      "lastName": "Dupont",
      "phone": "+33 6 12 34 56 78",
      "isActive": true,
      "createdAt": "2024-12-18T20:00:00.000Z",
      "updatedAt": "2024-12-18T20:00:00.000Z",
      "roles": []
    }
  ],
  "meta": {
    "timestamp": "1702929600000",
    "page": 1,
    "limit": 20,
    "total": 1,
    "totalPages": 1
  }
}
```

#### 3. Récupérer un utilisateur par ID
**GET** `/users/{id}`

Récupère les détails d'un utilisateur spécifique.

**Réponse (200 OK)** :
```json
{
  "data": {
    "id": 1,
    "email": "user@example.com",
    "firstName": "Jean",
    "lastName": "Dupont",
    "phone": "+33 6 12 34 56 78",
    "isActive": true,
    "createdAt": "2024-12-18T20:00:00.000Z",
    "updatedAt": "2024-12-18T20:00:00.000Z",
    "roles": []
  },
  "meta": {
    "timestamp": "1702929600000"
  }
}
```

**Erreur (404 Not Found)** :
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "User with ID 999 not found",
    "details": {}
  }
}
```

#### 4. Mettre à jour un utilisateur
**PUT** `/users/{id}`

Met à jour les informations d'un utilisateur existant.

**Body (JSON)** :
```json
{
  "firstName": "Jean-Pierre",
  "phone": "+33 6 98 76 54 32",
  "isActive": false
}
```

**Réponse (200 OK)** :
```json
{
  "data": {
    "id": 1,
    "email": "user@example.com",
    "firstName": "Jean-Pierre",
    "lastName": "Dupont",
    "phone": "+33 6 98 76 54 32",
    "isActive": false,
    "createdAt": "2024-12-18T20:00:00.000Z",
    "updatedAt": "2024-12-18T20:15:00.000Z",
    "roles": []
  },
  "meta": {
    "timestamp": "1702930500000"
  }
}
```

**Règles métier** :
- Tous les champs sont optionnels
- Si l'email est modifié, il doit rester unique
- Si le mot de passe est modifié, il sera hashé automatiquement

#### 5. Supprimer un utilisateur
**DELETE** `/users/{id}`

Supprime un utilisateur (soft delete - l'enregistrement reste en base avec une date de suppression).

**Réponse (204 No Content)** :
Aucun contenu retourné en cas de succès.

**Règles métier** :
- La suppression est "douce" (soft delete) - l'utilisateur n'est pas physiquement supprimé
- Le champ `deletedAt` est renseigné avec la date de suppression

## Gestion des Erreurs

Toutes les erreurs suivent le format standardisé défini dans `standardisation_api_rest.md` :

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Message d'erreur explicite",
    "details": {
      "field": "nom_du_champ",
      "constraint": "contrainte_violée"
    }
  }
}
```

### Codes d'erreur courants

| Code HTTP | Code Erreur | Description |
|-----------|-------------|-------------|
| 400 | BAD_REQUEST | Paramètres de requête invalides |
| 400 | VALIDATION_ERROR | Erreur de validation des données |
| 404 | NOT_FOUND | Ressource non trouvée |
| 409 | CONFLICT | Conflit (ex: email déjà existant) |
| 500 | INTERNAL_SERVER_ERROR | Erreur interne du serveur |

## Sécurité

### Hashage des mots de passe
Les mots de passe sont stockés de manière sécurisée :
- Utilisation de **bcrypt** avec un salt de 10 rounds
- Les mots de passe en clair ne sont jamais stockés en base
- Les réponses API n'incluent jamais le hash du mot de passe

### Protection des données sensibles
- Le champ `passwordHash` est exclu de toutes les réponses API
- Le champ `deletedAt` est également masqué dans les réponses

## Cas d'Usage Métier

### 1. Création d'un nouveau compte client
**Scénario** : Un nouveau client s'inscrit sur la plateforme

**Flux** :
1. Le client fournit son email, mot de passe et informations personnelles
2. Le système vérifie l'unicité de l'email
3. Le mot de passe est hashé avec bcrypt
4. Le compte est créé avec le statut "actif"
5. Le client peut immédiatement utiliser son compte

### 2. Modification du profil utilisateur
**Scénario** : Un utilisateur met à jour ses informations personnelles

**Flux** :
1. L'utilisateur modifie son prénom, nom ou téléphone
2. Le système met à jour uniquement les champs fournis
3. La date de modification est automatiquement mise à jour

### 3. Désactivation d'un compte
**Scénario** : Un administrateur désactive temporairement un compte

**Flux** :
1. L'administrateur met à jour le champ `isActive` à `false`
2. L'utilisateur ne peut plus se connecter
3. Le compte peut être réactivé ultérieurement

### 4. Consultation de la liste des utilisateurs
**Scénario** : Un administrateur consulte tous les utilisateurs inscrits

**Flux** :
1. L'administrateur demande la liste avec pagination
2. Le système retourne les utilisateurs par page de 20 (par défaut)
3. Les métadonnées incluent le nombre total et le nombre de pages

## Évolutions Futures

### Fonctionnalités prévues
- **Authentification JWT** : Génération et validation de tokens d'authentification
- **Gestion avancée des rôles** : Endpoints pour attribuer/retirer des rôles aux utilisateurs
- **Recherche et filtres** : Recherche par email, nom, statut actif
- **Validation d'email** : Processus de confirmation d'email lors de l'inscription
- **Récupération de mot de passe** : Mécanisme de réinitialisation sécurisé

## Intégration avec d'autres microservices

### CartService
Le UserService fournit l'identifiant utilisateur nécessaire au CartService pour gérer les paniers individuels.

### OrderService
L'OrderService utilise les identifiants utilisateurs pour associer les commandes aux clients.

## Base de Données

### Configuration
- **Type** : MySQL
- **Host** : user-db (Docker network)
- **Port** : 3306 (interne) / 3308 (externe)
- **Base** : user_database

### Tables
- `users` : Stockage des utilisateurs
- `roles` : Stockage des rôles
- `user_roles` : Table de liaison many-to-many

### Stratégie de migration
- Synchronisation automatique désactivée en production
- Utilisation de migrations TypeORM recommandée pour les changements de schéma

## Conformité aux Standards

Cette API respecte les standards définis dans `standardisation_api_rest.md` :
- ✅ Endpoints orientés ressources avec pluriel
- ✅ Pas de verbes dans les URLs
- ✅ Format JSON avec camelCase
- ✅ Réponses uniformisées avec `data` et `meta`
- ✅ Codes HTTP appropriés (200, 201, 204, 400, 404, 409, 500)
- ✅ Erreurs normalisées avec `error.code`, `error.message`, `error.details`
- ✅ Pagination avec `page` et `limit`
- ✅ Documentation JSDoc dans le code

## Support et Contact

Pour toute question sur cette API :
- Équipe : Mouhcine & Vincent
- Repository : https://github.com/vincent-agi/microservices
