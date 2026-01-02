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

### 2. Bases de Données et Administration

#### Configuration des Bases de Données

Chaque microservice dispose de sa propre base de données MySQL isolée, respectant le pattern "Database per Service".

**UserService Database:**
- Conteneur: `user-mysql-dev`
- Image: mysql:8.0
- Port externe: 3308
- Port interne: 3306
- Base de données: `db_user_database`
- Utilisateur: `db_user`
- Mot de passe: `db_user_password`
- Accès externe: `mysql -h 127.0.0.1 -P 3308 -u db_user -pdb_user_password`

**CartService Database:**
- Conteneur: `cart-mysql-dev`
- Image: mysql:8.0
- Port externe: 3307
- Port interne: 3306
- Base de données: `cart_db`
- Utilisateur: `root`
- Mot de passe: `root`
- Accès externe: `mysql -h 127.0.0.1 -P 3307 -u root -proot`

**OrderService Database:**
- Conteneur: `order-mysql-dev`
- Image: mysql:8.0
- Port externe: 3309
- Port interne: 3306
- Base de données: `order_database`
- Utilisateur: `order_db_user`
- Mot de passe: `order_password`
- Accès externe: `mysql -h 127.0.0.1 -P 3309 -u order_db_user -porder_password`

#### phpMyAdmin - Interfaces d'Administration

Chaque service dispose de sa propre instance phpMyAdmin pour faciliter l'administration de la base de données.

**UserService phpMyAdmin:**
- URL: http://localhost:8083
- Conteneur: `user-phpmyadmin`
- Serveur MySQL: `user-db`
- Connexion: db_user / db_user_password (ou root / db_user_password)

**CartService phpMyAdmin:**
- URL: http://localhost:8082
- Conteneur: `cart-phpmyadmin`
- Serveur MySQL: `db`
- Connexion: root / root

**OrderService phpMyAdmin:**
- URL: http://localhost:8084
- Conteneur: `order-phpmyadmin`
- Serveur MySQL: `order-db`
- Connexion: order_db_user / order_password (ou root / order_password)

**Utilisation de phpMyAdmin:**
1. Accéder à l'URL correspondante dans le navigateur
2. Sélectionner le serveur (déjà pré-configuré)
3. Entrer les identifiants (utilisateur et mot de passe)
4. Gérer les bases de données, tables, requêtes SQL, etc.

### 3. Architecture Docker

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

### 4. Kafka - Message Broker

#### Configuration
- **Zookeeper**: Coordination des brokers Kafka
- **Kafka**: Broker de messages pour communication asynchrone
- **Kafka UI**: Interface web pour administrer Kafka
- **Port Kafka UI**: 8081

#### Cas d'usage prévus
- Notifications lors de création de commandes
- Synchronisation des données entre services
- Événements métier (création utilisateur, validation commande, etc.)

### 5. Tableau Récapitulatif des URLs et Accès

Ce tableau centralise tous les points d'accès de l'architecture microservices :

#### APIs via Traefik (Recommandé)

| Composant | Type | URL/Endpoint | Port | Authentification |
|-----------|------|--------------|------|------------------|
| UserService Auth | API | http://localhost/api/auth | 80 | - |
| UserService CRUD | API | http://localhost/api/users | 80 | JWT Bearer Token |
| CartService | API | http://localhost/api/cart | 80 | - |
| OrderService | API | http://localhost/api/orders | 80 | - |

#### APIs en Accès Direct (Développement)

| Composant | Type | URL/Endpoint | Port | Authentification |
|-----------|------|--------------|------|------------------|
| UserService | API | http://localhost:3000 | 3000 | JWT Bearer Token |
| CartService | API | http://localhost:5001 | 5001 | - |
| OrderService | API | http://localhost:8080 | 8080 | - |

#### Bases de Données MySQL

| Composant | Type | URL/Endpoint | Port | Authentification |
|-----------|------|--------------|------|------------------|
| UserService DB | MySQL | localhost:3308 | 3308 | db_user:db_user_password |
| CartService DB | MySQL | localhost:3307 | 3307 | root:root |
| OrderService DB | MySQL | localhost:3309 | 3309 | order_db_user:order_password |

#### Administration phpMyAdmin

| Composant | Type | URL/Endpoint | Port | Authentification |
|-----------|------|--------------|------|------------------|
| UserService | Web UI | http://localhost:8083 | 8083 | db_user:db_user_password |
| CartService | Web UI | http://localhost:8082 | 8082 | root:root |
| OrderService | Web UI | http://localhost:8084 | 8084 | order_db_user:order_password |

#### Infrastructure

| Composant | Type | URL/Endpoint | Port | Authentification |
|-----------|------|--------------|------|------------------|
| Traefik Dashboard | Web UI | http://localhost:8090 | 8090 | admin:admin123 |
| Kafka UI | Web UI | http://localhost:8081 | 8081 | - |
| Kafka Broker | Service | localhost:29092 | 29092 | - |
| Zookeeper | Service | localhost:2181 | 2181 | - |

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

### Kafka - Message Broker

#### Choix Technique

Apache Kafka a été choisi comme système de messagerie pour plusieurs raisons:
- **Communication asynchrone**: Permet le découplage des microservices
- **Scalabilité**: Gestion efficace de grands volumes de messages
- **Résilience**: Persistance des messages et garantie de livraison
- **Event-driven architecture**: Support natif des patterns événementiels
- **Performance**: Très haute capacité de traitement (throughput)

#### Architecture Kafka

**Composants:**
- **Zookeeper** (Port 2181): Coordination et gestion du cluster Kafka
- **Kafka Broker** (Port 9092): Serveur de messages
- **Kafka UI** (Port 8081): Interface d'administration web

**Configuration:**
```yaml
KAFKA_ADVERTISED_LISTENERS: 
  - PLAINTEXT://kafka:9092 (communication interne Docker)
  - PLAINTEXT_HOST://localhost:29092 (accès externe)
KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
KAFKA_AUTO_CREATE_TOPICS_ENABLE: true
```

#### Topics Pré-configurés

Les topics suivants sont automatiquement créés au démarrage via le service `kafka-init`:

**Order Service Topics:**
- `order.created` - Événement de création de commande
- `order.updated` - Événement de mise à jour de commande
- `order.cancelled` - Événement d'annulation de commande

**Payment Topics:**
- `payment.pending` - Paiement en cours
- `payment.completed` - Paiement réussi
- `payment.failed` - Paiement échoué

**Cart Service Topics:**
- `cart.item.added` - Article ajouté au panier
- `cart.item.removed` - Article retiré du panier
- `cart.cleared` - Panier vidé

**User Service Topics:**
- `user.registered` - Nouvel utilisateur enregistré
- `user.updated` - Profil utilisateur mis à jour

**Configuration des topics:**
- Partitions: 3 (pour permettre la parallélisation)
- Replication Factor: 1 (suffisant pour le développement)
- Cleanup Policy: Delete (messages supprimés après rétention)

#### Utilisation dans les Microservices

**Exemple avec Node.js (UserService) - KafkaJS:**

```javascript
// Installation
npm install kafkajs

// Configuration du producer
import { Kafka } from 'kafkajs';

const kafka = new Kafka({
  clientId: 'user-service',
  brokers: ['kafka:9092']
});

const producer = kafka.producer();

// Envoyer un événement
await producer.connect();
await producer.send({
  topic: 'user.registered',
  messages: [
    {
      key: userId,
      value: JSON.stringify({
        userId,
        email,
        timestamp: new Date().toISOString()
      })
    }
  ]
});

// Configuration du consumer
const consumer = kafka.consumer({ groupId: 'user-service-group' });
await consumer.connect();
await consumer.subscribe({ topic: 'payment.completed' });

await consumer.run({
  eachMessage: async ({ topic, partition, message }) => {
    console.log({
      topic,
      value: message.value.toString()
    });
  }
});
```

**Exemple avec Python (CartService) - kafka-python:**

```python
# Installation
pip install kafka-python

# Configuration du producer
from kafka import KafkaProducer
import json

producer = KafkaProducer(
    bootstrap_servers=['kafka:9092'],
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

# Envoyer un événement
producer.send('cart.item.added', {
    'userId': user_id,
    'productId': product_id,
    'quantity': quantity,
    'timestamp': datetime.now().isoformat()
})
producer.flush()

# Configuration du consumer
from kafka import KafkaConsumer

consumer = KafkaConsumer(
    'order.created',
    bootstrap_servers=['kafka:9092'],
    group_id='cart-service-group',
    value_deserializer=lambda m: json.loads(m.decode('utf-8'))
)

for message in consumer:
    print(f"Received: {message.value}")
```

**Exemple avec Java (OrderService) - Spring Kafka:**

```java
// Installation (pom.xml)
<dependency>
    <groupId>org.springframework.kafka</groupId>
    <artifactId>spring-kafka</artifactId>
</dependency>

// Configuration (application.yml)
spring:
  kafka:
    bootstrap-servers: kafka:9092
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.springframework.kafka.support.serializer.JsonSerializer
    consumer:
      group-id: order-service-group
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.springframework.kafka.support.serializer.JsonDeserializer

// Producer
@Service
public class OrderEventProducer {
    @Autowired
    private KafkaTemplate<String, OrderEvent> kafkaTemplate;
    
    public void sendOrderCreated(OrderEvent event) {
        kafkaTemplate.send("order.created", event.getOrderId(), event);
    }
}

// Consumer
@Service
public class PaymentEventConsumer {
    @KafkaListener(topics = "payment.completed", groupId = "order-service-group")
    public void consume(PaymentEvent event) {
        System.out.println("Payment completed: " + event);
    }
}
```

#### Bonnes Pratiques

**Format des Messages:**
```json
{
  "eventId": "uuid-v4",
  "eventType": "order.created",
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "1.0",
  "data": {
    "orderId": "order-123",
    "userId": "user-456",
    "amount": 99.99,
    "items": [...]
  }
}
```

**Recommandations:**
1. **Idempotence**: Inclure un `eventId` unique pour détecter les doublons
2. **Schema versioning**: Inclure une version pour gérer l'évolution des messages
3. **Timestamp**: Toujours inclure la date/heure de l'événement
4. **Error handling**: Implémenter des dead letter queues pour les échecs
5. **Monitoring**: Utiliser Kafka UI pour surveiller les topics et consommateurs

#### Accès et Monitoring

**Kafka UI (Provectus):**
- URL: http://localhost:8081
- Fonctionnalités:
  - Visualisation des topics et messages
  - Gestion des consumer groups
  - Monitoring des performances
  - Configuration des brokers

**Ligne de commande:**
```bash
# Lister les topics
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092

# Décrire un topic
docker exec kafka kafka-topics --describe --topic order.created --bootstrap-server localhost:9092

# Consommer des messages (pour debug)
docker exec kafka kafka-console-consumer --topic order.created --from-beginning --bootstrap-server localhost:9092

# Produire un message (pour test)
docker exec -it kafka kafka-console-producer --topic order.created --bootstrap-server localhost:9092
```

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
