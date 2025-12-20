# Guide d'Utilisation - Traefik API Gateway

## Introduction

Traefik est l'API Gateway centralisé de la plateforme microservices. Il gère le routage des requêtes HTTP vers les différents microservices.

## Accès au Dashboard

### URL et Authentification

**URL:** http://localhost:8090

**Identifiants:**
- **Utilisateur:** `admin`
- **Mot de passe:** `admin123`

**Note:** Ces identifiants sont configurés en clair dans le fichier docker-compose.yml et doivent être changés en production.

### Navigation dans le Dashboard

Le dashboard Traefik affiche:

1. **HTTP Routers**: Liste des routes configurées
2. **HTTP Services**: Services backend disponibles
3. **HTTP Middlewares**: Middlewares appliqués (strip prefix, auth, etc.)
4. **Entrypoints**: Points d'entrée (web:80, websecure:443, traefik:8080)

## Routes Configurées

### UserService

**Route externe:**
```
http://localhost/api/users
```

**Configuration:**
- **Rule:** `Host('localhost') && PathPrefix('/api/users')`
- **Entrypoint:** web (port 80)
- **Backend:** user-api-dev:3000
- **Middleware:** Strip prefix `/api/users`

**Exemples:**
```bash
# Liste des utilisateurs
curl http://localhost/api/users

# Créer un utilisateur
curl -X POST http://localhost/api/users \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"pass123","firstName":"Test","lastName":"User"}'

# Inscription
curl -X POST http://localhost/api/users/../auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"new@example.com","password":"pass123","firstName":"New","lastName":"User"}'
```

**Note:** Le middleware strip prefix retire `/api/users` avant de transférer au service, donc:
- `http://localhost/api/users` → `http://user-api-dev:3000/`
- `http://localhost/api/users/123` → `http://user-api-dev:3000/123`

### CartService

**Route externe:**
```
http://localhost/api/cart
```

**Configuration:**
- **Rule:** `Host('localhost') && PathPrefix('/api/cart')`
- **Entrypoint:** web (port 80)
- **Backend:** cart-api-dev:5020
- **Middleware:** Strip prefix `/api/cart`

**Exemples:**
```bash
# Voir le panier d'un utilisateur
curl http://localhost/api/cart/user/123 \
  -H "Authorization: Bearer <token>"

# Ajouter un article au panier
curl -X POST http://localhost/api/cart \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"productId":1,"quantity":2}'
```

### OrderService

**Route externe:**
```
http://localhost/api/orders
```

**Configuration:**
- **Rule:** `Host('localhost') && PathPrefix('/api/orders')`
- **Entrypoint:** web (port 80)
- **Backend:** order-api-dev:8080
- **Middleware:** Strip prefix `/api/orders`

**Exemples:**
```bash
# Liste des commandes
curl http://localhost/api/orders \
  -H "Authorization: Bearer <token>"

# Créer une commande
curl -X POST http://localhost/api/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"cartId":123}'
```

## Accès Direct vs Via Traefik

### Avantages de Traefik

**Point d'entrée unique:**
- Simplifie la configuration client
- Masque la complexité de l'infrastructure
- Facilite le load balancing futur

**Routage intelligent:**
- Basé sur le path (préfixe)
- Support de multiples backends
- Health checks automatiques

**Monitoring:**
- Dashboard en temps réel
- Métriques de trafic
- État des services

### Quand utiliser l'accès direct?

**Développement:**
```bash
# UserService direct
curl http://localhost:3000/users

# CartService direct
curl http://localhost:5001/paniers

# OrderService direct
curl http://localhost:8080/orders
```

**Debugging:**
- Tester un service spécifique
- Bypass Traefik pour isoler les problèmes
- Développement de nouvelles fonctionnalités

**Production:**
- Uniquement via Traefik
- Ports directs non exposés publiquement

## Configuration pour Nouveaux Services

### Ajouter un nouveau microservice

**1. Docker-compose du service:**

```yaml
services:
  api:
    # ... configuration du service ...
    networks:
      - microservices-network
    labels:
      # Activer Traefik
      - "traefik.enable=true"
      
      # Configuration du routeur
      - "traefik.http.routers.myservice-api.rule=Host(`localhost`) && PathPrefix(`/api/myservice`)"
      - "traefik.http.routers.myservice-api.entrypoints=web"
      - "traefik.http.routers.myservice-api.service=myservice-api"
      
      # Configuration du service backend
      - "traefik.http.services.myservice-api.loadbalancer.server.port=8000"
      
      # Middleware strip prefix
      - "traefik.http.routers.myservice-api.middlewares=myservice-api-stripprefix"
      - "traefik.http.middlewares.myservice-api-stripprefix.stripprefix.prefixes=/api/myservice"

networks:
  microservices-network:
    external: true
```

**2. Redémarrer les services:**

```bash
./microservices.sh restart
```

**3. Vérifier dans le dashboard:**
- Aller sur http://localhost:8090
- Vérifier que le nouveau router apparaît
- Tester l'endpoint

## Middlewares Disponibles

### Strip Prefix

**Fonction:** Retire un préfixe du path avant de transférer au backend

**Configuration:**
```yaml
- "traefik.http.middlewares.service-stripprefix.stripprefix.prefixes=/api/service"
- "traefik.http.middlewares.service-stripprefix.stripprefix.forceSlash=false"
```

**Exemple:**
- Requête: `http://localhost/api/users/123`
- Après middleware: `http://user-api-dev:3000/123`

### Basic Auth (Dashboard)

**Fonction:** Protection par authentification basique

**Configuration:**
```yaml
- "traefik.http.middlewares.dashboard-auth.basicauth.users=admin:$$apr1$$hash$$..."
```

**Génération du hash:**
```bash
# Avec Docker
docker run --rm httpd:2.4-alpine htpasswd -nb admin password123

# Avec htpasswd local
htpasswd -nb admin password123
```

### Headers (Sécurité)

**Fonction:** Ajouter des headers de sécurité

**Configuration:**
```yaml
- "traefik.http.middlewares.security-headers.headers.framedeny=true"
- "traefik.http.middlewares.security-headers.headers.sslredirect=true"
```

### CORS

**Fonction:** Gérer les requêtes cross-origin

**Configuration:**
```yaml
- "traefik.http.middlewares.cors.headers.accesscontrolallowmethods=GET,POST,PUT,DELETE"
- "traefik.http.middlewares.cors.headers.accesscontrolalloworigin=*"
- "traefik.http.middlewares.cors.headers.accesscontrolmaxage=100"
- "traefik.http.middlewares.cors.headers.addvaryheader=true"
```

## Debugging avec Traefik

### Vérifier les logs

**Logs en temps réel:**
```bash
docker logs -f traefik
```

**Filtrer les erreurs:**
```bash
docker logs traefik 2>&1 | grep ERROR
```

### Problèmes courants

#### Service non routé

**Symptôme:** 404 Not Found via Traefik

**Vérifications:**
1. Le service a-t-il le label `traefik.enable=true`?
2. Le réseau est-il correct (`microservices-network`)?
3. Le router rule est-il correct?
4. Le service est-il démarré?

**Debug:**
```bash
# Vérifier les conteneurs
docker ps | grep api

# Vérifier le réseau
docker network inspect microservices-network

# Voir la config Traefik
curl http://localhost:8090/api/rawdata
```

#### Timeout

**Symptôme:** 504 Gateway Timeout

**Causes possibles:**
- Service backend lent ou non démarré
- Port incorrect dans les labels
- Service crashé

**Debug:**
```bash
# Tester le service directement
curl http://localhost:3000/users

# Vérifier les logs du service
docker logs user-api-dev

# Vérifier le health check
docker ps --format "table {{.Names}}\t{{.Status}}"
```

#### Strip prefix incorrect

**Symptôme:** 404 sur le service backend

**Cause:** Le path après strip prefix ne correspond pas aux routes du service

**Solution:**
- Vérifier les routes du service
- Ajuster le prefix ou la configuration du service
- Option: Ne pas utiliser strip prefix

## Monitoring

### Métriques Disponibles

**Via Dashboard:**
- Nombre de requêtes par router
- Temps de réponse moyen
- Erreurs 4xx et 5xx
- État des services backend

### Prometheus (Futur)

**Configuration:**
```yaml
# Dans docker-compose.yml
command:
  - "--metrics.prometheus=true"
  - "--metrics.prometheus.buckets=0.1,0.3,1.2,5.0"
```

**Endpoint:** http://localhost:8090/metrics

## Sécurité

### HTTPS (Production)

**Configuration Let's Encrypt:**
```yaml
command:
  - "--certificatesresolvers.letsencrypt.acme.email=admin@example.com"
  - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
  - "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"

routers:
  - "traefik.http.routers.service.tls.certresolver=letsencrypt"
```

### Rate Limiting

**Protection contre le spam:**
```yaml
- "traefik.http.middlewares.ratelimit.ratelimit.average=100"
- "traefik.http.middlewares.ratelimit.ratelimit.burst=50"
```

### IP Whitelist

**Restriction d'accès:**
```yaml
- "traefik.http.middlewares.ipwhitelist.ipwhitelist.sourcerange=127.0.0.1/32,192.168.1.0/24"
```

## Bonnes Pratiques

### Nommage

**Convention:**
- Router: `{service}-api`
- Service: `{service}-api`
- Middleware: `{service}-api-{fonction}`

**Exemple:**
```yaml
- "traefik.http.routers.user-api.rule=..."
- "traefik.http.services.user-api.loadbalancer..."
- "traefik.http.middlewares.user-api-stripprefix..."
```

### Configuration

**Utiliser les labels Docker:**
- Configuration au plus près du service
- Versionning avec le code
- Facilite la maintenance

**Éviter:**
- Fichiers de configuration statiques
- Configuration centralisée complexe

### Tests

**Valider les changements:**
```bash
# Tester la route
curl -I http://localhost/api/users

# Vérifier dans le dashboard
open http://localhost:8090

# Consulter les logs
docker logs traefik | tail -20
```

## Commandes Utiles

```bash
# Redémarrer Traefik seul
docker-compose restart traefik

# Voir la configuration complète
docker-compose config

# Lister les routes actives
curl http://localhost:8090/api/http/routers

# Lister les services
curl http://localhost:8090/api/http/services

# Health check
curl http://localhost:8090/ping
```

## Ressources

**Documentation officielle:**
- https://doc.traefik.io/traefik/
- https://doc.traefik.io/traefik/routing/routers/
- https://doc.traefik.io/traefik/middlewares/overview/

**Dashboard:**
- http://localhost:8090

**API:**
- http://localhost:8090/api/overview

## Conclusion

Traefik simplifie grandement la gestion du routage dans une architecture microservices. Son dashboard intuitif et sa configuration par labels Docker en font un outil puissant pour le développement et la production.
