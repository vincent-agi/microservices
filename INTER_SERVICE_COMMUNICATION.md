# Test de Communication Inter-Services

Ce script démontre la communication entre les microservices de la plateforme e-commerce.

## 📋 Vue d'Ensemble

Le script `test-inter-service-communication.sh` exécute un workflow complet qui prouve que les microservices peuvent échanger entre eux pour répondre aux besoins de l'application.

## 🎯 Objectif

Prouver que chaque microservice est capable d'aller chercher les informations adéquates dans les autres microservices, conformément aux exigences du projet.

## 🏗️ Architecture Testée

```
┌─────────────┐       ┌─────────────┐       ┌──────────────┐
│ UserService │◄──────┤ CartService │◄──────┤ OrderService │
│  (NestJS)   │       │   (Flask)   │       │ (Spring Boot)│
│  Port 3000  │       │  Port 5001  │       │  Port 8080   │
└─────────────┘       └─────────────┘       └──────────────┘
      ▲                      ▲                      ▲
      │                      │                      │
      └──────────────────────┴──────────────────────┘
         Communication Inter-Services (HTTP REST)
```

## 🔄 Communications Inter-Services Testées

### 1. CartService → UserService
**Validation d'utilisateur lors de la création de panier**

```python
# CartService (Python/Flask)
from utils.user_service import verify_user_exists

user_exists, error_msg = verify_user_exists(user_id)
if not user_exists:
    return error_response('USER_NOT_FOUND', error_msg)
```

**Endpoint utilisé:**
- `GET http://user-api-dev:3000/users/{userId}`

### 2. OrderService → UserService
**Validation d'utilisateur lors de la création de commande**

```java
// OrderService (Java/Spring Boot)
@Autowired
private UserServiceClient userServiceClient;

if (!userServiceClient.verifyUserExists(userId)) {
    throw new IllegalArgumentException("User not found");
}
```

**Endpoint utilisé:**
- `GET http://user-api-dev:3000/users/{userId}`

### 3. OrderService → CartService
**Récupération des paniers d'un utilisateur**

```java
// OrderService (Java/Spring Boot)
@Autowired
private CartServiceClient cartServiceClient;

Object cartData = cartServiceClient.getCartByUserId(userId);
```

**Endpoint utilisé:**
- `GET http://cart-api-dev:5020/paniers/user/{userId}`

### 4. OrderService → UserService + CartService
**Endpoint enrichi: Agrégation de données depuis plusieurs services**

```java
// OrderService récupère les données de l'utilisateur ET du panier
public Map<String, Object> getEnrichedOrderData(OrderDTO order) {
    Object userData = userServiceClient.getUserInfo(userId);
    Object cartData = cartServiceClient.getCartByUserId(userId);
    // ... combine les données
}
```

**Endpoint exposé:**
- `GET http://localhost:8080/api/orders/{id}/enriched`

## 📝 Phases du Test

### Phase 1: UserService - Création des Utilisateurs
- ✅ Inscription de 2 utilisateurs
- ✅ Récupération de la liste des utilisateurs
- ✅ Validation de l'API REST

### Phase 2: CartService → UserService
- ✅ Création de paniers avec validation utilisateur
- ✅ **Communication inter-service:** CartService interroge UserService
- ✅ Test de rejet d'un utilisateur inexistant

### Phase 3: CartService - Gestion des Articles
- ✅ Ajout d'articles aux paniers
- ✅ Calcul automatique des totaux

### Phase 4: OrderService → UserService
- ✅ Création de commandes avec validation utilisateur
- ✅ **Communication inter-service:** OrderService interroge UserService

### Phase 4.5: OrderService → UserService + CartService
- ✅ Récupération enrichie de commande
- ✅ **Communication multi-services:** OrderService → UserService + CartService
- ✅ Agrégation de données depuis plusieurs microservices

### Phase 5: Récupération de Données Croisées
- ✅ Paniers d'un utilisateur via CartService
- ✅ Commandes d'un utilisateur via OrderService
- ✅ Données utilisateur via UserService

### Phase 6: Health Checks
- ✅ Vérification de l'état de tous les services

## 🚀 Utilisation

### Prérequis

1. Tous les microservices doivent être démarrés:
```bash
./microservices.sh start
```

2. Vérifier que les services sont accessibles:
```bash
curl http://localhost:3000/users    # UserService
curl http://localhost:5001/health   # CartService
curl http://localhost:8080/api/orders/health  # OrderService
```

### Exécution du Script

```bash
./test-inter-service-communication.sh
```

Le script va:
1. Créer des utilisateurs
2. Créer des paniers (en validant les utilisateurs)
3. Ajouter des articles
4. Créer des commandes (en validant les utilisateurs)
5. Tester l'agrégation de données multi-services
6. Afficher un résumé complet

## 📊 Résultats Attendus

### Succès
```
═══════════════════════════════════════════════════════════════
✓ COMMUNICATION INTER-SERVICES VALIDÉE
═══════════════════════════════════════════════════════════════

✓ UserService:
  - Utilisateurs créés
  - API REST fonctionnelle

✓ CartService:
  - Paniers créés avec validation utilisateur
  - Communication validée: CartService → UserService

✓ OrderService:
  - Commandes créées avec validation utilisateur
  - Communication validée: OrderService → UserService
  - Communication validée: OrderService → CartService
  - Endpoint enrichi: Agrégation multi-services

✓ Tous les microservices communiquent correctement entre eux!
```

## 🔍 Détails Techniques

### URLs des Services (Réseau Docker)

Les services communiquent entre eux via le réseau Docker `microservices-network`:

| Service      | URL Interne (Docker)        | Port |
|--------------|----------------------------|------|
| UserService  | http://user-api-dev:3000   | 3000 |
| CartService  | http://cart-api-dev:5020   | 5020 |
| OrderService | http://order-api-dev:8080  | 8080 |

### Configuration

**CartService (.env):**
```env
USER_SERVICE_URL=http://user-api-dev:3000
```

**OrderService (application.properties):**
```properties
userservice.url=${USER_SERVICE_URL:http://user-api-dev:3000}
cartservice.url=${CART_SERVICE_URL:http://cart-api-dev:5020}
```

## 🛠️ Implémentation

### CartService - UserService Client
Fichier: `CartService/app/utils/user_service.py`

```python
def verify_user_exists(user_id):
    user_service_url = os.getenv('USER_SERVICE_URL', 'http://user-api:3000')
    response = requests.get(f"{user_service_url}/users/{user_id}")
    return response.status_code == 200
```

### OrderService - UserService Client
Fichier: `OrderService/src/main/java/com/example/orderservice/client/UserServiceClient.java`

```java
@Component
public class UserServiceClient {
    @Value("${userservice.url:http://user-api-dev:3000}")
    private String userServiceUrl;
    
    public boolean verifyUserExists(Integer userId) {
        String url = userServiceUrl + "/users/" + userId;
        return restTemplate.getForObject(url, Object.class) != null;
    }
}
```

### OrderService - CartService Client
Fichier: `OrderService/src/main/java/com/example/orderservice/client/CartServiceClient.java`

```java
@Component
public class CartServiceClient {
    @Value("${cartservice.url:http://cart-api-dev:5020}")
    private String cartServiceUrl;
    
    public Object getCartByUserId(Integer userId) {
        String url = cartServiceUrl + "/paniers/user/" + userId;
        return restTemplate.getForObject(url, Object.class);
    }
}
```

## 📚 Documentation Associée

- [Documentation Technique](./docs/TECHNICAL_DOCUMENTATION.md)
- [Documentation Métier](./docs/BUSINESS_DOCUMENTATION.md)
- [Guide Traefik](./docs/TRAEFIK_GUIDE.md)
- [README Principal](./README.md)

## ✅ Validation

Ce script démontre que:

1. ✅ **Chaque microservice peut échanger avec les autres**
   - CartService communique avec UserService
   - OrderService communique avec UserService
   - OrderService communique avec CartService

2. ✅ **Les microservices fonctionnent bien ensemble**
   - Workflow complet e-commerce testé
   - Validation croisée des données
   - Agrégation de données depuis plusieurs sources

3. ✅ **Les microservices peuvent aller chercher les informations adéquates**
   - Validation d'utilisateurs
   - Récupération de paniers
   - Enrichissement de données

## 🎓 Pour Aller Plus Loin

### Améliorations Possibles

1. **Circuit Breaker**: Implémenter Resilience4j pour gérer les pannes
2. **Cache**: Ajouter un cache Redis pour les données utilisateur
3. **Message Queue**: Utiliser Kafka pour les communications asynchrones
4. **API Gateway**: Routage via Traefik pour toutes les communications
5. **Service Discovery**: Utiliser Consul ou Eureka
6. **Distributed Tracing**: Implémenter OpenTelemetry/Jaeger

### Tests Additionnels

```bash
# Test via Traefik (API Gateway)
curl http://localhost/api/users
curl http://localhost/api/cart
curl http://localhost/api/orders

# Test de charge
ab -n 1000 -c 10 http://localhost/api/users

# Test de résilience
docker stop user-api-dev
./test-inter-service-communication.sh  # Voir comment les services réagissent
```

## 📞 Support

Pour toute question sur la communication inter-services:
1. Consulter la [Documentation Technique](./docs/TECHNICAL_DOCUMENTATION.md)
2. Vérifier les logs: `docker logs [service-name]`
3. Inspecter le réseau: `docker network inspect microservices-network`

---

**Note**: Ce script est conçu pour un environnement de développement. En production, des mécanismes supplémentaires de résilience, sécurité et monitoring seraient nécessaires.
