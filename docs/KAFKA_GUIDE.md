# Guide Kafka - Message Queue Configuration

## Vue d'ensemble

Ce guide décrit la configuration Kafka mise en place pour le système de microservices e-commerce. Kafka permet la communication asynchrone entre les services via des événements.

## Architecture

### Composants

1. **Zookeeper** (Port 2181)
   - Coordonne le cluster Kafka
   - Gère les métadonnées et l'état du cluster
   - Healthcheck configuré pour vérifier la disponibilité

2. **Kafka Broker** (Ports 9092, 29092)
   - Serveur de messages principal
   - Port 9092: Communication interne entre conteneurs Docker
   - Port 29092: Accès depuis l'hôte local
   - Healthcheck pour garantir la disponibilité avant démarrage des dépendances

3. **Kafka UI** (Port 8081)
   - Interface web d'administration
   - Visualisation des topics, messages, et consumer groups
   - Monitoring en temps réel
   - URL: http://localhost:8081

4. **Kafka Init**
   - Service d'initialisation automatique
   - Crée les topics pré-configurés au démarrage
   - S'exécute une fois puis se termine

## Topics Pré-configurés

Tous les topics sont créés automatiquement au démarrage de l'infrastructure avec la configuration suivante:
- **Partitions**: 3 (permet la parallélisation des consommateurs)
- **Replication Factor**: 1 (suffisant pour le développement)

### Topics Order Service

| Topic | Description | Émis par | Consommé par |
|-------|-------------|----------|--------------|
| `order.created` | Commande créée | OrderService | NotificationService, InventoryService |
| `order.updated` | Statut de commande modifié | OrderService | NotificationService |
| `order.cancelled` | Commande annulée | OrderService | PaymentService, NotificationService |

### Topics Payment

| Topic | Description | Émis par | Consommé par |
|-------|-------------|----------|--------------|
| `payment.pending` | Paiement initié | PaymentService | OrderService |
| `payment.completed` | Paiement réussi | PaymentService | OrderService, NotificationService |
| `payment.failed` | Paiement échoué | PaymentService | OrderService, NotificationService |

### Topics Cart Service

| Topic | Description | Émis par | Consommé par |
|-------|-------------|----------|--------------|
| `cart.item.added` | Article ajouté au panier | CartService | RecommendationService |
| `cart.item.removed` | Article retiré du panier | CartService | AnalyticsService |
| `cart.cleared` | Panier vidé | CartService | AnalyticsService |

### Topics User Service

| Topic | Description | Émis par | Consommé par |
|-------|-------------|----------|--------------|
| `user.registered` | Nouvel utilisateur | UserService | NotificationService, WelcomeService |
| `user.updated` | Profil utilisateur modifié | UserService | AnalyticsService |

## Accès et Monitoring

### Kafka UI (Provectus)

**URL**: http://localhost:8081

**Fonctionnalités disponibles**:
- 📊 Liste et détails des topics
- 💬 Visualisation des messages
- 👥 Gestion des consumer groups
- ⚙️ Configuration des brokers
- 📈 Statistiques en temps réel

### Ligne de Commande

**Lister les topics**:
```bash
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092
```

**Détails d'un topic**:
```bash
docker exec kafka kafka-topics --describe --topic order.created --bootstrap-server localhost:9092
```

**Consommer des messages (debug)**:
```bash
docker exec kafka kafka-console-consumer \
  --topic order.created \
  --from-beginning \
  --bootstrap-server localhost:9092
```

**Produire un message de test**:
```bash
docker exec -it kafka kafka-console-producer \
  --topic order.created \
  --bootstrap-server localhost:9092
```

## Intégration dans les Microservices

### Node.js / TypeScript (UserService)

**Installation**:
```bash
npm install kafkajs
```

**Configuration Producer**:
```typescript
// src/kafka/kafka.config.ts
import { Kafka } from 'kafkajs';

export const kafka = new Kafka({
  clientId: 'user-service',
  brokers: ['kafka:9092']
});

export const producer = kafka.producer();
```

**Émission d'événements**:
```typescript
// src/auth/auth.service.ts
import { producer } from '../kafka/kafka.config';

async onModuleInit() {
  await producer.connect();
}

async register(registerDto: RegisterDto) {
  const user = await this.createUser(registerDto);
  
  // Émettre l'événement user.registered
  await producer.send({
    topic: 'user.registered',
    messages: [
      {
        key: user.id,
        value: JSON.stringify({
          eventId: uuidv4(),
          eventType: 'user.registered',
          timestamp: new Date().toISOString(),
          version: '1.0',
          data: {
            userId: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName
          }
        })
      }
    ]
  });
  
  return user;
}
```

**Consommation d'événements**:
```typescript
// src/kafka/kafka.consumer.ts
import { kafka } from './kafka.config';

const consumer = kafka.consumer({ groupId: 'user-service-group' });

export async function startConsumer() {
  await consumer.connect();
  await consumer.subscribe({ 
    topics: ['payment.completed', 'order.created'] 
  });

  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      const event = JSON.parse(message.value.toString());
      console.log(`Received event from ${topic}:`, event);
      
      switch(topic) {
        case 'payment.completed':
          await handlePaymentCompleted(event);
          break;
        case 'order.created':
          await handleOrderCreated(event);
          break;
      }
    }
  });
}
```

### Python (CartService)

**Installation**:
```bash
pip install kafka-python
```

**Configuration Producer**:
```python
# kafka_config.py
from kafka import KafkaProducer
import json

producer = KafkaProducer(
    bootstrap_servers=['kafka:9092'],
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)
```

**Émission d'événements**:
```python
# cart/service.py
from kafka_config import producer
import uuid
from datetime import datetime

def add_item_to_cart(user_id, product_id, quantity):
    # Logique d'ajout au panier
    cart_item = add_to_database(user_id, product_id, quantity)
    
    # Émettre l'événement cart.item.added
    event = {
        'eventId': str(uuid.uuid4()),
        'eventType': 'cart.item.added',
        'timestamp': datetime.utcnow().isoformat(),
        'version': '1.0',
        'data': {
            'userId': user_id,
            'productId': product_id,
            'quantity': quantity,
            'cartId': cart_item.cart_id
        }
    }
    
    producer.send('cart.item.added', event)
    producer.flush()
    
    return cart_item
```

**Consommation d'événements**:
```python
# kafka_consumer.py
from kafka import KafkaConsumer
import json

consumer = KafkaConsumer(
    'order.created',
    bootstrap_servers=['kafka:9092'],
    group_id='cart-service-group',
    value_deserializer=lambda m: json.loads(m.decode('utf-8'))
)

def start_consumer():
    for message in consumer:
        event = message.value
        print(f"Received event: {event}")
        
        if event['eventType'] == 'order.created':
            handle_order_created(event)
```

### Java / Spring Boot (OrderService)

**Installation (pom.xml)**:
```xml
<dependency>
    <groupId>org.springframework.kafka</groupId>
    <artifactId>spring-kafka</artifactId>
</dependency>
```

**Configuration (application.yml)**:
```yaml
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
      properties:
        spring.json.trusted.packages: "*"
```

**Producer**:
```java
// config/KafkaProducerConfig.java
@Service
public class OrderEventProducer {
    
    @Autowired
    private KafkaTemplate<String, OrderEvent> kafkaTemplate;
    
    public void sendOrderCreated(OrderEvent event) {
        kafkaTemplate.send("order.created", event.getOrderId(), event);
    }
}

// service/OrderService.java
@Service
public class OrderService {
    
    @Autowired
    private OrderEventProducer eventProducer;
    
    public Order createOrder(OrderDto orderDto) {
        Order order = saveOrder(orderDto);
        
        // Émettre l'événement
        OrderEvent event = OrderEvent.builder()
            .eventId(UUID.randomUUID().toString())
            .eventType("order.created")
            .timestamp(Instant.now())
            .version("1.0")
            .data(OrderEventData.builder()
                .orderId(order.getId())
                .userId(order.getUserId())
                .amount(order.getTotalAmount())
                .items(order.getItems())
                .build())
            .build();
            
        eventProducer.sendOrderCreated(event);
        
        return order;
    }
}
```

**Consumer**:
```java
// consumer/PaymentEventConsumer.java
@Service
public class PaymentEventConsumer {
    
    @KafkaListener(topics = "payment.completed", groupId = "order-service-group")
    public void handlePaymentCompleted(PaymentEvent event) {
        log.info("Payment completed: {}", event);
        
        // Mettre à jour le statut de la commande
        updateOrderStatus(event.getData().getOrderId(), OrderStatus.PAID);
    }
    
    @KafkaListener(topics = "payment.failed", groupId = "order-service-group")
    public void handlePaymentFailed(PaymentEvent event) {
        log.info("Payment failed: {}", event);
        
        // Gérer l'échec du paiement
        updateOrderStatus(event.getData().getOrderId(), OrderStatus.PAYMENT_FAILED);
    }
}
```

## Format Standard des Messages

Pour assurer la compatibilité entre services, tous les messages doivent suivre ce format:

```json
{
  "eventId": "550e8400-e29b-41d4-a716-446655440000",
  "eventType": "order.created",
  "timestamp": "2026-01-02T16:30:00.000Z",
  "version": "1.0",
  "data": {
    "orderId": "order-123",
    "userId": "user-456",
    "amount": 99.99,
    "items": [
      {
        "productId": "prod-789",
        "quantity": 2,
        "price": 49.99
      }
    ]
  }
}
```

**Champs obligatoires**:
- `eventId`: Identifiant unique (UUID v4) pour la déduplication
- `eventType`: Type d'événement (correspond au nom du topic)
- `timestamp`: Date/heure ISO 8601 de l'événement
- `version`: Version du schéma de données (pour évolution)
- `data`: Données spécifiques à l'événement

## Bonnes Pratiques

### 1. Idempotence
Toujours vérifier `eventId` pour éviter de traiter deux fois le même événement:

```typescript
const processedEvents = new Set<string>();

async function handleEvent(event: KafkaEvent) {
  if (processedEvents.has(event.eventId)) {
    console.log('Event already processed, skipping');
    return;
  }
  
  await processEvent(event);
  processedEvents.add(event.eventId);
}
```

### 2. Gestion des Erreurs
Implémenter une stratégie de retry avec backoff exponentiel:

```typescript
async function handleMessage(message) {
  const maxRetries = 3;
  let attempt = 0;
  
  while (attempt < maxRetries) {
    try {
      await processMessage(message);
      return;
    } catch (error) {
      attempt++;
      if (attempt >= maxRetries) {
        // Envoyer vers Dead Letter Queue
        await sendToDeadLetterQueue(message, error);
        throw error;
      }
      await sleep(Math.pow(2, attempt) * 1000);
    }
  }
}
```

### 3. Schema Evolution
Toujours maintenir la rétrocompatibilité:

```json
{
  "version": "2.0",
  "data": {
    "orderId": "order-123",
    "newField": "new-value",
    "deprecatedField": null  // Garder pour compatibilité v1
  }
}
```

### 4. Logging
Logger tous les événements importants:

```typescript
logger.info('Event produced', {
  topic: 'order.created',
  eventId: event.eventId,
  timestamp: event.timestamp
});

logger.info('Event consumed', {
  topic: message.topic,
  partition: message.partition,
  offset: message.offset,
  eventId: event.eventId
});
```

## Dépannage

### Topics non créés
```bash
# Vérifier les logs du service kafka-init
docker logs kafka-init

# Recréer les topics manuellement si nécessaire
docker exec kafka kafka-topics --create \
  --if-not-exists \
  --bootstrap-server localhost:9092 \
  --partitions 3 \
  --replication-factor 1 \
  --topic order.created
```

### Kafka UI ne se connecte pas
```bash
# Redémarrer Kafka UI
docker restart kafka-ui

# Vérifier la connectivité
docker exec kafka-ui ping kafka
```

### Messages non consommés
```bash
# Vérifier les consumer groups
docker exec kafka kafka-consumer-groups --list --bootstrap-server localhost:9092

# Voir le lag d'un groupe
docker exec kafka kafka-consumer-groups \
  --describe \
  --group order-service-group \
  --bootstrap-server localhost:9092
```

### Problèmes de performance
```bash
# Augmenter le nombre de partitions
docker exec kafka kafka-topics --alter \
  --topic order.created \
  --partitions 6 \
  --bootstrap-server localhost:9092
```

## Sécurité

### Développement
- Pas d'authentification (PLAINTEXT)
- Accessible uniquement via le réseau Docker

### Production (Recommandations)
- Activer SASL/SSL pour l'authentification
- Utiliser TLS pour chiffrer les communications
- Configurer ACLs pour restreindre l'accès aux topics
- Augmenter le replication factor à 3 minimum
- Monitorer avec Prometheus + Grafana

## Références

- [Documentation Kafka](https://kafka.apache.org/documentation/)
- [KafkaJS](https://kafka.js.org/)
- [kafka-python](https://kafka-python.readthedocs.io/)
- [Spring Kafka](https://spring.io/projects/spring-kafka)
- [Kafka UI](https://github.com/provectus/kafka-ui)
