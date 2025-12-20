# Documentation Métier - Authentification et Gestion des Utilisateurs

## Contexte Business

Dans le cadre d'une plateforme e-commerce, la gestion des utilisateurs et leur authentification sont des fonctionnalités critiques qui permettent:

1. **Identification des clients**: Associer les commandes et paniers à des utilisateurs spécifiques
2. **Personnalisation**: Offrir une expérience personnalisée basée sur l'historique
3. **Sécurité**: Protéger les données sensibles et les transactions
4. **Traçabilité**: Suivre les actions des utilisateurs pour l'analyse et le support

## Fonctionnalités Métier

### 1. Inscription Utilisateur (Register)

#### Cas d'usage
Un nouveau visiteur souhaite créer un compte sur la plateforme pour effectuer des achats.

#### Processus métier

1. **Collecte des informations**:
   - Email (identifiant unique)
   - Mot de passe (sécurisé, minimum 6 caractères)
   - Prénom
   - Nom de famille

2. **Validation**:
   - Email valide et non déjà utilisé
   - Mot de passe respecte les critères de sécurité
   - Tous les champs obligatoires remplis

3. **Création du compte**:
   - Enregistrement de l'utilisateur dans la base de données
   - Activation automatique du compte (statut: actif)
   - Génération d'un token d'authentification

4. **Résultat**:
   - Utilisateur créé et directement connecté
   - Token JWT fourni pour les futures requêtes
   - Prêt à utiliser les services (panier, commandes)

#### Règles métier

- **Unicité de l'email**: Un email ne peut être utilisé qu'une seule fois
- **Mot de passe fort**: Minimum 6 caractères (recommandé: 8+ avec caractères spéciaux)
- **Activation immédiate**: Pas de validation email (simplifié pour MVP)
- **Données obligatoires**: Email, mot de passe, prénom, nom

#### Erreurs possibles

| Code | Message | Raison |
|------|---------|--------|
| 409  | Email already exists | L'email est déjà utilisé par un autre compte |
| 400  | Validation failed | Données invalides (format email, mot de passe trop court, etc.) |

### 2. Connexion Utilisateur (Login)

#### Cas d'usage
Un utilisateur existant souhaite se connecter à son compte pour accéder à ses données et effectuer des actions.

#### Processus métier

1. **Authentification**:
   - Saisie de l'email
   - Saisie du mot de passe

2. **Vérification**:
   - Email existe dans la base de données
   - Mot de passe correspond au hash enregistré
   - Compte est actif (non désactivé)

3. **Génération de session**:
   - Création d'un token JWT
   - Durée de validité: 1 heure
   - Inclusion de l'ID utilisateur et email dans le token

4. **Résultat**:
   - Utilisateur authentifié
   - Token JWT fourni
   - Accès aux services personnalisés

#### Règles métier

- **Vérification stricte**: Email ET mot de passe doivent correspondre
- **Compte actif**: Seuls les comptes actifs peuvent se connecter
- **Session temporaire**: Token valide 1 heure, renouvellement nécessaire après
- **Sécurité**: Mot de passe hashé, jamais stocké en clair

#### Erreurs possibles

| Code | Message | Raison |
|------|---------|--------|
| 401  | Invalid credentials | Email ou mot de passe incorrect |
| 401  | Account is not active | Compte désactivé par l'administrateur |
| 400  | Validation failed | Format de données invalide |

### 3. Utilisation du Token

#### Cas d'usage
Après connexion, l'utilisateur effectue des actions nécessitant une authentification (créer un panier, passer commande, voir son profil).

#### Processus métier

1. **Inclusion du token**:
   - Header HTTP: `Authorization: Bearer <token>`
   - Envoyé avec chaque requête authentifiée

2. **Validation automatique**:
   - Vérification de la signature du token
   - Vérification de l'expiration
   - Extraction des données utilisateur

3. **Accès aux ressources**:
   - Identification automatique de l'utilisateur
   - Autorisation d'accès aux données personnelles
   - Actions contextualisées

#### Règles métier

- **Expiration**: Token expire après 1 heure, reconnexion nécessaire
- **Sécurité**: Token signé cryptographiquement, impossible à falsifier
- **Portée**: Token valide pour tous les microservices de la plateforme

## Intégration avec les Autres Services

### CartService - Gestion du Panier

**Scénarios:**

1. **Création de panier**:
   - Utilisateur authentifié crée un panier
   - Panier associé automatiquement à son ID utilisateur
   - Persistance du panier entre sessions

2. **Récupération du panier**:
   - CartService extrait l'ID utilisateur du token JWT
   - Recherche le panier actif pour cet utilisateur
   - Affichage des articles et totaux

**Communication:**
```
Client -> Traefik -> CartService
CartService vérifie le token JWT
CartService utilise user.userId pour associer le panier
```

### OrderService - Gestion des Commandes

**Scénarios:**

1. **Création de commande**:
   - Utilisateur authentifié passe commande
   - Validation du panier via CartService
   - Vérification de l'utilisateur via UserService
   - Création de la commande avec userId

2. **Historique des commandes**:
   - OrderService extrait userId du token
   - Récupère toutes les commandes de cet utilisateur
   - Affichage de l'historique complet

**Communication:**
```
Client -> Traefik -> OrderService
OrderService -> UserService (vérification utilisateur)
OrderService -> CartService (récupération panier)
OrderService créé la commande avec userId
```

### Communication Inter-Services

#### Exemple: Validation d'une commande

```
1. Client envoie token JWT à OrderService
2. OrderService vérifie le token (userId=123)
3. OrderService appelle UserService pour vérifier l'utilisateur:
   GET http://user-api-dev:3000/users/123
   Authorization: Bearer <token>
4. OrderService appelle CartService pour le panier:
   GET http://cart-api-dev:5020/cart/user/123
   Authorization: Bearer <token>
5. OrderService crée la commande
6. OrderService publie événement "ORDER_CREATED" sur Kafka
7. Autres services réagissent (notification, stock, etc.)
```

## Parcours Utilisateur Type

### Nouveau Client

```
1. Visite du site e-commerce
2. Parcours des produits (sans compte)
3. Décision d'acheter
4. Inscription (POST /auth/register)
   → Compte créé, token reçu
5. Ajout produits au panier (POST /cart, avec token)
   → Panier associé à son compte
6. Validation de la commande (POST /orders, avec token)
   → Commande créée et liée à son compte
7. Déconnexion après 1h (token expiré)
```

### Client Existant

```
1. Visite du site
2. Connexion (POST /auth/login)
   → Token reçu
3. Récupération panier existant (GET /cart, avec token)
   → Panier précédent rechargé
4. Ajout de nouveaux produits
5. Consultation historique commandes (GET /orders, avec token)
   → Liste des commandes passées
6. Nouvelle commande
7. Déconnexion
```

## Événements Métier

### Lors de l'inscription

**Événement:** `USER_CREATED`

**Données:**
```json
{
  "userId": 123,
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "createdAt": "2024-01-15T10:30:00Z"
}
```

**Consommateurs:**
- **NotificationService**: Envoie email de bienvenue
- **AnalyticsService**: Enregistre nouvelle inscription
- **CartService**: Prépare panier vide pour le nouvel utilisateur

### Lors de la connexion

**Événement:** `USER_LOGGED_IN`

**Données:**
```json
{
  "userId": 123,
  "email": "user@example.com",
  "loginAt": "2024-01-15T14:20:00Z"
}
```

**Consommateurs:**
- **AnalyticsService**: Enregistre connexion
- **SecurityService**: Détection d'activités suspectes
- **RecommendationService**: Prépare recommandations personnalisées

## Métriques Métier

### KPIs à suivre

1. **Taux de conversion inscription**:
   - Visiteurs vs inscriptions
   - Objectif: > 5%

2. **Taux d'activation**:
   - Inscriptions vs premiers achats
   - Objectif: > 30%

3. **Taux de rétention**:
   - Connexions récurrentes
   - Objectif: > 40% à 30 jours

4. **Session moyenne**:
   - Durée avant expiration token
   - Objectif: < 1h (renouvelable)

## Règles de Gestion

### Désactivation de Compte

**Critères:**
- Demande de l'utilisateur (RGPD)
- Fraude détectée
- Inactivité prolongée (> 2 ans)
- Décision administrative

**Processus:**
- Statut `isActive` passe à 0
- Impossibilité de connexion
- Conservation des données pour historique commandes
- Anonymisation possible après délai légal

### Réactivation de Compte

**Critères:**
- Demande de l'utilisateur
- Résolution du problème de sécurité
- Décision administrative

**Processus:**
- Vérification identité
- Statut `isActive` passe à 1
- Notification à l'utilisateur
- Accès restauré

## Conformité et Sécurité

### RGPD

**Données personnelles collectées:**
- Email (identifiant)
- Prénom et nom
- Téléphone (optionnel)
- Mot de passe hashé

**Droits des utilisateurs:**
- Droit d'accès: GET /users/:id
- Droit de modification: PUT /users/:id
- Droit à l'effacement: DELETE /users/:id (soft delete)
- Droit à la portabilité: Export JSON des données

### Sécurité

**Mesures:**
- Mots de passe hashés (bcrypt)
- Tokens JWT signés
- HTTPS en production
- Rate limiting sur auth endpoints
- Logs d'authentification
- Détection de tentatives frauduleuses

## Évolutions Futures

### Court Terme (MVP)
- ✅ Inscription et connexion basiques
- ✅ Token JWT
- ✅ Intégration avec microservices

### Moyen Terme
- [ ] Email de confirmation
- [ ] Réinitialisation mot de passe
- [ ] Profil utilisateur enrichi
- [ ] Adresses de livraison multiples
- [ ] Préférences utilisateur

### Long Terme
- [ ] OAuth2 (Google, Facebook)
- [ ] Authentification à deux facteurs (2FA)
- [ ] Biométrie
- [ ] Sessions multiples
- [ ] Refresh tokens
- [ ] Gestion des rôles avancée (admin, vendeur, etc.)

## Conclusion

Le système d'authentification mis en place constitue la base de la plateforme e-commerce. Il permet:
- Une identification sécurisée des utilisateurs
- Une expérience personnalisée
- Une intégration fluide avec tous les microservices
- Une base solide pour les évolutions futures
