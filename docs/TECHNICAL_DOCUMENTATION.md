# Documentation Technique - Traefik & Architecture Microservices

## Vue d'ensemble

Ce document détaille les choix techniques et l'architecture mise en place pour le projet microservices e-commerce.

## Architecture Infrastructure

### 1. Traefik - API Gateway et Reverse Proxy

#### Choix Technique
Traefik a été choisi comme API Gateway pour plusieurs raisons:
- **Découverte automatique des services**: Traefik se configure automatiquement en détectant les conteneurs Docker
- **Reverse Proxy moderne**: Support natif de Docker, Kubernetes, et autres orchestrateurs
- **Dashboard intégré**: Interface web pour monitorer les routes et services
- **Configuration par labels**: Configuration déclarative directement dans docker-compose
- **Performance**: Écrit en Go, Traefik est très performant et léger

#### Configuration

**Port d'écoute:**
- Port 80: HTTP pour l'accès aux microservices
- Port 443: HTTPS (prévu pour production)
- Port 8090: Dashboard d'administration

**Réseau:**
- Réseau partagé `microservices-network` (bridge externe)
- Tous les microservices se connectent à ce réseau
- Permet la communication inter-services et le routage via Traefik

**Authentification Dashboard:**
- Type: Basic Auth
- Utilisateur: `admin`
- Mot de passe: `admin123`
- Hash généré: `admin:$apr1$oUypAAUA$bG4cWLaO335CQdt6chRKP0`

**Accès:**
```
Dashboard: http://localhost:8090
Authentification requise: admin / admin123
```

#### Routage des Microservices

**UserService:**
- URL externe (authentification): `http://localhost/api/auth`
- URL externe (utilisateurs): `http://localhost/api/users`
- Port interne: 3000
- Middleware: Strip prefix `/api` (pour les deux routes)
- Service backend: `user-api-dev:3000`

**CartService:**
- URL externe: `http://localhost/api/cart`
- Port interne: 5020
- Middleware: Strip prefix `/api`
- Service backend: `cart-api-dev:5020`

**OrderService:**
- URL externe: `http://localhost/api/orders`
- Port interne: 8080
- Middleware: Strip prefix `/api`
- Service backend: `order-api-dev:8080`

### 2. Architecture Docker

#### Réseau Externe

Le réseau `microservices-network` est défini comme **externe** dans les docker-compose individuels:

```yaml
networks:
  microservices-network:
    external: true
```

**Justification:**
- Permet à tous les services de communiquer entre eux
- Le réseau est créé par le docker-compose racine
- Les services individuels s'y connectent sans le recréer
- Facilite l'ajout de nouveaux services

#### Ordre de Démarrage

1. **Infrastructure** (docker-compose racine):
   - Création du réseau `microservices-network`
   - Démarrage de Zookeeper
   - Démarrage de Kafka
   - Démarrage de Kafka UI
   - Démarrage de Traefik

2. **Microservices** (via microservices.sh):
   - CartService + base de données
   - OrderService + base de données
   - UserService + base de données

### 3. Kafka - Message Broker

#### Configuration
- **Zookeeper**: Coordination des brokers Kafka
- **Kafka**: Broker de messages pour communication asynchrone
- **Kafka UI**: Interface web pour administrer Kafka
- **Port Kafka UI**: 8081

#### Cas d'usage prévus
- Notifications lors de création de commandes
- Synchronisation des données entre services
- Événements métier (création utilisateur, validation commande, etc.)

## Authentification JWT - UserService

### Choix Technique

L'authentification JWT (JSON Web Token) a été choisie pour:
- **Stateless**: Pas besoin de stocker les sessions côté serveur
- **Scalabilité**: Facilite le load balancing entre instances
- **Sécurité**: Token signé cryptographiquement
- **Standard**: Compatible avec tous les clients HTTP
- **Microservices**: Idéal pour architectures distribuées

### Architecture Authentification

#### Modules NestJS

**AuthModule** (`src/auth/auth.module.ts`):
- Module principal pour l'authentification
- Configure JwtModule avec secret et expiration
- Importe PassportModule pour la gestion des stratégies

**AuthService** (`src/auth/auth.service.ts`):
- Logique métier pour register et login
- Hash des mots de passe avec bcrypt (10 rounds)
- Génération des tokens JWT
- Validation des credentials

**AuthController** (`src/auth/auth.controller.ts`):
- Endpoint POST `/auth/register`
- Endpoint POST `/auth/login`
- Validation des DTOs avec class-validator

#### Stratégie JWT

**JwtStrategy** (`src/auth/jwt.strategy.ts`):
- Extraction du token depuis header Authorization
- Validation de la signature JWT
- Récupération des données utilisateur

**JwtAuthGuard** (`src/auth/jwt-auth.guard.ts`):
- Guard NestJS pour protéger les routes
- Usage: `@UseGuards(JwtAuthGuard)`

### Configuration JWT

**Variables d'environnement** (`.env`):
```env
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRATION=1h
```

**Paramètres:**
- Secret: Clé de signature des tokens (à changer en production)
- Expiration: 1 heure par défaut
- Algorithme: HS256 (HMAC SHA-256)

### Flux d'Authentification

#### 1. Inscription (Register)

**Endpoint:** `POST /auth/register`

**Payload:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123",
  "firstName": "John",
  "lastName": "Doe"
}
```

**Processus:**
1. Validation des données (DTOs)
2. Vérification que l'email n'existe pas
3. Hash du mot de passe (bcrypt, 10 rounds)
4. Création de l'utilisateur en base
5. Génération du token JWT
6. Retour user + access_token

**Réponse:**
```json
{
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "firstName": "John",
      "lastName": "Doe"
    },
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00.000Z"
  }
}
```

#### 2. Connexion (Login)

**Endpoint:** `POST /auth/login`

**Payload:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123"
}
```

**Processus:**
1. Validation des données (DTOs)
2. Recherche de l'utilisateur par email
3. Vérification du mot de passe (bcrypt.compare)
4. Vérification que le compte est actif
5. Génération du token JWT
6. Retour user + access_token

**Réponse:** Identique à Register

#### 3. Utilisation du Token

**Header d'authentification:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Protection d'une route:**
```typescript
@UseGuards(JwtAuthGuard)
@Get('profile')
getProfile(@Request() req) {
  return req.user; // { userId: 1, email: "user@example.com" }
}
```

### Sécurité

#### Mesures Implémentées

1. **Hash des mots de passe**: bcrypt avec 10 rounds
2. **Validation stricte**: class-validator sur tous les DTOs
3. **Tokens signés**: JWT avec secret cryptographique
4. **Expiration des tokens**: 1 heure par défaut
5. **Vérification du statut**: Seuls les comptes actifs peuvent se connecter

#### Bonnes Pratiques

**À faire en production:**
- Changer `JWT_SECRET` pour une valeur aléatoire forte
- Augmenter le nombre de rounds bcrypt (12-14)
- Implémenter refresh tokens
- Ajouter rate limiting sur login/register
- Utiliser HTTPS uniquement
- Implémenter logout avec blacklist de tokens
- Ajouter 2FA (authentification à deux facteurs)

### Tests

**Scripts de test fournis:**
- `test-api-register.sh`: Test des inscriptions
- `test-api-login.sh`: Test des connexions

**Scénarios testés:**
- ✅ Inscription valide
- ✅ Login valide
- ✅ Email déjà existant
- ✅ Mot de passe incorrect
- ✅ Email inexistant
- ✅ Mot de passe trop court
- ✅ Extraction du token JWT

## Communication Inter-Services

### Scénarios d'Utilisation

#### 1. Via Traefik (Externe)
```bash
# Client externe -> Traefik -> UserService
curl http://localhost/api/users
```

#### 2. Entre Microservices (Interne)
```javascript
// CartService appelle UserService
const response = await fetch('http://user-api-dev:3000/users/123', {
  headers: {
    'Authorization': `Bearer ${jwtToken}`
  }
});
```

#### 3. Direct (Développement)
```bash
# Accès direct au service
curl http://localhost:3000/users
```

### Recommandations

**Pour la communication inter-services:**
1. Utiliser les noms de conteneurs Docker
2. Passer le token JWT pour l'authentification
3. Gérer les timeouts et retries
4. Logger toutes les requêtes inter-services
5. Utiliser Kafka pour les opérations asynchrones

## Monitoring et Debugging

### Logs

**Voir les logs d'un service:**
```bash
./microservices.sh logs user-api
./microservices.sh logs traefik
```

**Logs en temps réel:**
```bash
docker logs -f user-api-dev
docker logs -f traefik
```

### Dashboard Traefik

**Informations disponibles:**
- Liste des routes configurées
- État des services backend
- Statistiques de trafic
- Configuration en temps réel

**URL:** http://localhost:8090

### Kafka UI

**Informations disponibles:**
- Topics Kafka
- Messages en attente
- Groupes de consommateurs
- Configuration des brokers

**URL:** http://localhost:8081

## Scripts de Gestion

### microservices.sh

**Commandes disponibles:**
```bash
./microservices.sh start    # Démarre infrastructure + microservices
./microservices.sh stop     # Arrête tout
./microservices.sh restart  # Redémarre tout
./microservices.sh status   # État des services
./microservices.sh logs     # Logs de tous les services
./microservices.sh clean    # Nettoyage complet
```

## Dépendances

### UserService

**Runtime:**
- @nestjs/jwt: 10.2.0
- @nestjs/passport: 10.0.3
- passport: 0.7.0
- passport-jwt: 4.0.1
- bcrypt: 6.0.0

**Dev:**
- @types/passport-jwt: 4.0.1

## Conclusion

Cette architecture offre:
- ✅ Scalabilité horizontale des microservices
- ✅ Routage centralisé via Traefik
- ✅ Authentification sécurisée avec JWT
- ✅ Communication inter-services facilitée
- ✅ Monitoring et debugging simplifiés
- ✅ Séparation claire des responsabilités
