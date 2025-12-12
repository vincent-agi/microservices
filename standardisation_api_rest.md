# Standardisation des API REST en Microservices

## 1. Convention de nommage et structure des endpoints

### 1.1. Endpoints orientés ressources

-   GET /users
-   POST /users
-   GET /users/{id}
-   PUT /users/{id}
-   DELETE /users/{id}

### 1.2. Pluriel obligatoire

-   users, orders, products

### 1.4. Pas de verbes dans l'URL

-   ❌ /getUser\
-   ✔ /users/{id}

### 1.5. Actions métier

-   POST /orders/{id}/cancel\
-   POST /users/{id}/activate

------------------------------------------------------------------------

## 2. Contrats d'API

### 2.1. Énumérations documentées

Toujours exposer la liste exacte des valeurs autorisées.

### 2.2. JSON obligatoire

-   UTF-8
-   camelCase (obligatoire)

------------------------------------------------------------------------

## 3. Requêtes et réponses

### 3.1. Réponse uniformisée

``` json
{
  "data": {},
  "meta": {
    "timestamp": "1765526686824", // December 12th 2025, 9:04:46 am CET+01:00
  }
}
```

`data` stock les données renvoyées par l'API et `meta`sont les métadonnées (des informations sur les données demandées).
Le minimum à avoir est le `timestamp`. Si necessaire on ajoutera plus tard d'autres informations.

### 3.2. Pas de réponses 200 avec erreurs

Respecter la sémantique des verbes HTTP.
Par exemple : 
❌ Renvoi 200 + "error": "not found". `200` veut dire `ok, ca c'est bien passé`.
✔ Utiliser les bons codes HTTP. Ici avec le `not found`, il fadraut un code HTTP `400`

------------------------------------------------------------------------

## 4. Codes HTTP

### Succès

-   200 OK
-   201 Created
-   204 No Content

### Erreurs client

-   400, 401, 403, 404, 409, 422

### Erreurs serveur

-   500, 503

------------------------------------------------------------------------

## 5. Erreurs normalisées
Le format des erreurs doit être normalisé. Sinon on aura des problèmes importants plus tard.
Donc une erreur renvoyée par l'API prendra la forme suivante :

``` json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid format",
    "details": {
      "field": "email",
      "contraint": "required"
    }
  }
}
```

`code` : c'est un code d'erreur qu'on pourra facilement repérer et utiliser en programmation.
`message` : c'est un message humain friendly qui a pour but d'être lu par le developpeur pour comprendre le problème.
`details` : C'est un objet JSON qui comprends les détails de l'erreur.

Le contenu de l'objet `details` n'est pas notre priorité. Il faut simplment avoir des informations dedans un cas d'erreur pour nous permettre de comprendre.
------------------------------------------------------------------------

## 6. Filtrage, pagination, tri

### Pagination

-   GET /users?page=1&limit=20

### Tri

-   sort=createdAt&order=desc

### Filtrage

-   status=PAID&from=2024-01-01

------------------------------------------------------------------------

## 7. Sécurité

-   JWT ou OAuth2
-   Authorization: Bearer `<token>`{=html}
-   Rate-limiting minimal : 25 req/min (On verra plus tard pour le `rate-limiting`. Ce n'est pas la priorité)

------------------------------------------------------------------------

## 8. Documentation

Je vous recommande d'installer le package `Swagger` pour documenter votre API.

-   OpenAPI 3 obligatoire
-   /docs/openapi.json\
-   Swagger UI / Redoc

> Attention aussi a documenter votre code avec la syntaxe pour votre langage : 

- Format JSDoc pour `typescript` et `javascript`
- Format JavaDoc pour `Java`
- Format PyDoc pour `Python`

*S'il vous plait, fait bien la doc de votre code. Pas écrire des longues phrases. Simplement une phrase ou deux pour comprendre l'objectif de votre fonction, de votre classe, interface.*

> ChatGPT fais très bien la documentaiton de votre code
------------------------------------------------------------------------

## 9. Tests & Qualité

> Je vous recommande d'écrire les tests unitaire *AVANT* d'écrire votre code. Si vous faire un bon prompt détaillé, `ChatGPT` écrit bien les tests
-   Tests unitaires

------------------------------------------------------------------------

## 10. Microservices : isolation

-   Un microservice = un domaine métier

> Si on est dans `orderService` on ne traite pas la page de profil utilisateur.

------------------------------------------------------------------------

## 11. Observabilité (Bonus)

-   Logs JSON structurés
-   Endpoints /health et /metrics
