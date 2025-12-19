# Scripts de Tests API - CartService

Ce dossier contient des scripts bash pour tester tous les endpoints de l'API CartService.

## Prérequis

- Le service CartService doit être démarré : `docker compose up`
- `curl` doit être installé
- `jq` doit être installé (optionnel, pour un affichage JSON formaté)

## Installation de jq (si nécessaire)

```bash
# Ubuntu/Debian
sudo apt-get install jq

# MacOS
brew install jq

# Windows (avec Chocolatey)
choco install jq
```

## Scripts disponibles

### Tests individuels

#### Paniers (Shopping Carts)

| Script | Description | Usage |
|--------|-------------|-------|
| `test-api-create-panier.sh` | Teste la création de paniers | `./test-api-create-panier.sh` |
| `test-api-read-paniers.sh` | Teste la lecture des paniers | `./test-api-read-paniers.sh` |
| `test-api-update-panier.sh` | Teste la mise à jour des paniers | `./test-api-update-panier.sh [ID]` |
| `test-api-delete-panier.sh` | Teste la suppression de paniers | `./test-api-delete-panier.sh [ID]` |

#### Articles (Cart Items)

| Script | Description | Usage |
|--------|-------------|-------|
| `test-api-create-article.sh` | Teste la création d'articles | `./test-api-create-article.sh` |
| `test-api-read-articles.sh` | Teste la lecture des articles | `./test-api-read-articles.sh` |
| `test-api-update-article.sh` | Teste la mise à jour des articles | `./test-api-update-article.sh [ID]` |
| `test-api-delete-article.sh` | Teste la suppression d'articles | `./test-api-delete-article.sh [ID]` |

#### Santé du service

| Script | Description | Usage |
|--------|-------------|-------|
| `microservice-test.sh` | Vérifie que le service est disponible | `./microservice-test.sh` |

### Test complet

| Script | Description | Usage |
|--------|-------------|-------|
| `run-all-tests.sh` | Exécute tous les tests dans l'ordre | `./run-all-tests.sh` |

## Utilisation rapide

### Tester tous les endpoints

```bash
./run-all-tests.sh
```

### Tester un endpoint spécifique

```bash
# Créer des paniers
./test-api-create-panier.sh

# Lire les paniers
./test-api-read-paniers.sh

# Mettre à jour un panier
./test-api-update-panier.sh 1

# Supprimer un panier
./test-api-delete-panier.sh 2

# Créer des articles
./test-api-create-article.sh

# Lire les articles
./test-api-read-articles.sh

# Mettre à jour un article
./test-api-update-article.sh 1

# Supprimer un article
./test-api-delete-article.sh 2
```

## Exemples de réponses

### Succès - Création d'un panier

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
    "timestamp": 1734602400000
  }
}
```

### Succès - Création d'un article

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
    "timestamp": 1734602700000
  }
}
```

### Succès - Liste paginée

```json
{
  "data": [
    { /* panier ou article */ }
  ],
  "meta": {
    "timestamp": 1734602800000,
    "page": 1,
    "limit": 20,
    "total": 50,
    "totalPages": 3
  }
}
```

### Erreur - Ressource non trouvée

```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Panier with ID 9999 not found",
    "details": {}
  }
}
```

### Erreur - Validation

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Quantity must be greater than 0",
    "details": {
      "field": "quantity"
    }
  }
}
```

## Scénarios de test

### Workflow complet : Créer un panier et y ajouter des articles

```bash
# 1. Créer un panier
./test-api-create-panier.sh

# 2. Noter l'ID du panier créé (ex: 1)

# 3. Ajouter des articles au panier
./test-api-create-article.sh

# 4. Récupérer le panier avec ses articles
curl http://localhost:5001/paniers/1 | jq '.'

# 5. Mettre à jour la quantité d'un article
./test-api-update-article.sh 1

# 6. Supprimer un article
./test-api-delete-article.sh 2

# 7. Finaliser le panier
curl -X PUT http://localhost:5001/paniers/1 \
  -H "Content-Type: application/json" \
  -d '{"status": "completed"}' | jq '.'
```

## Tests de cas limites

Chaque script teste également des cas d'erreur :
- Ressources inexistantes (404)
- Validations (quantité <= 0, prix négatif)
- Contraintes métier (panier inexistant pour un article)

## Notes importantes

1. **Cascade DELETE** : La suppression d'un panier supprime automatiquement tous ses articles
2. **Calcul automatique** : Le `totalLine` est calculé automatiquement (quantity × unitPrice)
3. **Pagination** : Par défaut, limite à 20 résultats par page (max 100)
4. **UserService** : Si disponible, les userId sont validés lors de la création/modification de paniers

## Dépannage

### Le service n'est pas accessible

```bash
# Vérifier que le service est démarré
docker compose ps

# Démarrer le service
cd CartService
docker compose up -d

# Vérifier les logs
docker compose logs -f
```

### jq n'est pas installé

Si `jq` n'est pas installé, les scripts fonctionnent toujours mais la sortie JSON ne sera pas formatée. Pour voir la sortie JSON brute :

```bash
curl http://localhost:5001/paniers
```

### Erreur "Connection refused"

Le service n'est probablement pas démarré ou n'écoute pas sur le port 5001 :

```bash
# Vérifier que le service écoute sur le port 5001
netstat -tuln | grep 5001

# ou
lsof -i :5001
```

## Support

Pour plus d'informations sur l'API, consultez :
- `API_README.md` - Documentation technique complète
- `documentation_metier.md` - Documentation métier en français
