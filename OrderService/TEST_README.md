# OrderService - Tests API

## Description

Ce dossier contient les scripts de test pour l'API REST du microservice OrderService. Ces scripts utilisent `curl` pour tester tous les endpoints de l'API.

## Prérequis

- Le microservice OrderService doit être en cours d'exécution sur http://localhost:8080
- `curl` doit être installé sur votre système

## Scripts de test disponibles

### Tests Orders (Commandes)

1. **test-api-create-order.sh** : Teste la création de commandes
   - Création d'une commande simple
   - Création d'une commande avec des articles
   - Création avec différents statuts
   - Tests de validation d'erreurs

2. **test-api-read-orders.sh** : Teste la lecture des commandes
   - Récupération de toutes les commandes
   - Pagination personnalisée
   - Filtrage par userId
   - Filtrage par status
   - Récupération d'une commande par ID
   - Endpoint /api/orders/user/{userId}
   - Health check

3. **test-api-update-order.sh** : Teste la mise à jour des commandes
   - Mise à jour du statut
   - Mise à jour des adresses
   - Mise à jour du montant total
   - Mise à jour de plusieurs champs à la fois

4. **test-api-delete-order.sh** : Teste la suppression des commandes
   - Suppression d'une commande
   - Vérification de la suppression (404)

### Tests OrderItems (Articles de commande)

5. **test-api-create-orderitem.sh** : Teste la création d'articles de commande
   - Création d'un article dans une commande
   - Ajout de plusieurs articles
   - Tests d'erreurs (commande inexistante, validation)

6. **test-api-read-orderitems.sh** : Teste la lecture des articles de commande
   - Récupération de tous les articles
   - Pagination personnalisée
   - Filtrage par orderId
   - Récupération d'un article par ID
   - Endpoint /api/order-items/order/{orderId}

7. **test-api-update-orderitem.sh** : Teste la mise à jour des articles de commande
   - Mise à jour de la quantité
   - Mise à jour du prix unitaire
   - Mise à jour de plusieurs champs

8. **test-api-delete-orderitem.sh** : Teste la suppression des articles de commande
   - Suppression d'un article
   - Vérification de la suppression (404)

### Script global

9. **run-all-tests.sh** : Exécute tous les tests dans l'ordre

## Utilisation

### Exécuter un test spécifique

```bash
./test-api-create-order.sh
```

### Exécuter tous les tests

```bash
./run-all-tests.sh
```

## Format des réponses

Toutes les réponses de l'API suivent le format standardisé défini dans `standardisation_api_rest.md` :

### Réponse de succès

```json
{
  "data": { /* données */ },
  "meta": {
    "timestamp": "1734691845123"
  }
}
```

### Réponse paginée

```json
{
  "data": [ /* tableau de données */ ],
  "meta": {
    "timestamp": "1734691845123",
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

### Réponse d'erreur

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Message d'erreur",
    "details": { /* détails */ }
  }
}
```

## Codes HTTP attendus

- **200 OK** : Requête réussie (GET, PUT)
- **201 Created** : Ressource créée (POST)
- **204 No Content** : Suppression réussie (DELETE)
- **400 Bad Request** : Données invalides
- **404 Not Found** : Ressource non trouvée
- **500 Internal Server Error** : Erreur serveur

## Notes

- Les scripts créent des données de test qui peuvent persister dans la base de données
- Certains scripts créent des ressources temporaires avant de les supprimer
- Les ID utilisés dans les scripts (1, 9999, etc.) sont des exemples et peuvent nécessiter des ajustements selon votre base de données

## Dépannage

### Le service ne répond pas

Vérifiez que le service est bien démarré :
```bash
docker compose ps
docker logs order-api-dev
```

### Erreurs de connexion

Vérifiez que le port 8080 est bien accessible :
```bash
curl http://localhost:8080/api/orders/health
```

### Données incorrectes

Vous pouvez réinitialiser la base de données :
```bash
docker compose down -v
docker compose up
```

## Support

Pour toute question ou problème, consultez :
- La documentation métier : `documentation_metier.md`
- La documentation du README : `README.md`
- Les standards API : `../standardisation_api_rest.md`
