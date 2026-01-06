# Interface Utilisateur - Microservices E-Commerce

Interface web simple permettant de tester et démontrer le fonctionnement des différents microservices de la plateforme e-commerce.

## 🎯 Objectif

Cette interface fournit une façon conviviale d'interagir avec les API REST des trois microservices :
- **UserService** - Gestion des utilisateurs et authentification
- **CartService** - Gestion des paniers d'achat
- **OrderService** - Gestion des commandes

## 🚀 Démarrage

### Option 1: Via Docker (Recommandé)

L'interface est automatiquement déployée avec les autres services:

```bash
# Démarrer tous les services depuis la racine du projet
cd /path/to/microservices
./microservices.sh start
```

L'interface sera accessible sur:
- **Port direct**: http://localhost:3001
- **Via Traefik**: http://ui.localhost (nécessite une configuration DNS locale)

### Option 2: Accès Direct (Développement)

Pour tester l'interface sans Docker:

```bash
cd ui
# Ouvrir index.html dans un navigateur
# Ou utiliser un serveur HTTP local:
python3 -m http.server 8000
# Puis ouvrir http://localhost:8000
```

## 📖 Utilisation

### 1. Authentification

Commencez par l'onglet **Authentification** :
- **S'inscrire** : Créer un nouveau compte utilisateur
- **Se connecter** : Obtenir un token JWT pour les requêtes authentifiées

Le token est automatiquement stocké et utilisé pour les requêtes qui nécessitent une authentification.

### 2. UserService

L'onglet **Users Service** permet de :
- Lister tous les utilisateurs (requiert authentification)
- Créer de nouveaux utilisateurs (requiert authentification)

### 3. CartService

L'onglet **Cart Service** permet de :
- Lister tous les paniers (avec filtrage par utilisateur)
- Créer un nouveau panier pour un utilisateur
- Ajouter des articles à un panier
- Voir le détail d'un panier avec tous ses articles

### 4. OrderService

L'onglet **Order Service** permet de :
- Lister toutes les commandes (avec filtrage par utilisateur)
- Créer une nouvelle commande
- Ajouter des items à une commande existante

## 🔧 Configuration

Les URLs des services sont configurées dans `app.js`:

```javascript
const API_CONFIG = {
    userService: 'http://localhost/api',      // via Traefik
    cartService: 'http://localhost:5001',     // accès direct
    orderService: 'http://localhost:8080'     // accès direct
};
```

Vous pouvez modifier ces URLs selon votre environnement.

## 🏗️ Architecture

L'interface est construite avec:
- **HTML5** - Structure de la page
- **CSS3** - Styling moderne et responsive
- **Vanilla JavaScript** - Logique et appels API (pas de framework)

### Fichiers

```
ui/
├── index.html       # Structure HTML de l'interface
├── styles.css       # Styles CSS
├── app.js           # Logique JavaScript et appels API
├── nginx.conf       # Configuration nginx pour CORS
├── Dockerfile       # Image Docker nginx
└── README.md        # Cette documentation
```

## 🎨 Fonctionnalités

### Gestion de l'état
- Le token JWT est stocké dans `localStorage`
- Les informations de l'utilisateur connecté sont persistées
- Déconnexion en un clic

### Interface responsive
- Design adaptatif pour mobile et desktop
- Onglets pour organiser les différents services
- Messages de succès/erreur clairs

### Affichage des résultats
- Format JSON brut pour les développeurs
- Listes formatées pour les utilisateurs
- Messages d'erreur détaillés

## 🔐 Sécurité

- **CORS**: Configuré dans nginx pour permettre les requêtes cross-origin
- **JWT**: Token d'authentification stocké localement et envoyé avec les requêtes authentifiées
- **HTTPS**: Recommandé en production (actuellement HTTP pour le développement)

## 📝 Exemple de flux utilisateur

1. **Inscription**: Créer un compte dans l'onglet Authentification
2. **Connexion**: Se connecter pour obtenir un token JWT
3. **Créer un panier**: Aller dans Cart Service et créer un panier pour votre userId
4. **Ajouter des articles**: Ajouter des produits au panier créé
5. **Voir le panier**: Visualiser le panier avec le total calculé
6. **Créer une commande**: Créer une commande dans Order Service
7. **Ajouter des items**: Ajouter des produits à la commande

## 🐛 Dépannage

### L'interface ne charge pas
- Vérifier que le conteneur `microservices-ui` est démarré: `docker ps | grep ui`
- Vérifier les logs: `docker logs microservices-ui`

### Erreurs CORS
- Vérifier que nginx est bien configuré avec les headers CORS
- Pour le développement, utiliser les URL directes des services

### Erreurs d'authentification
- Vérifier que vous êtes bien connecté (indicateur en haut à droite)
- Le token peut expirer, reconnectez-vous si nécessaire

### Les services ne répondent pas
- Vérifier que tous les microservices sont démarrés: `./microservices.sh status`
- Vérifier les logs des services: `./microservices.sh logs [service]`

## 🔗 Liens utiles

- **Documentation principale**: `/README.md`
- **Documentation UserService**: `/UserService/README.md`
- **Documentation CartService**: `/CartService/API_README.md`
- **Documentation OrderService**: `/OrderService/README.md`
- **Traefik Dashboard**: http://localhost:8090 (admin/admin123)

## 👥 Équipe

Interface développée pour le projet Microservices E-Commerce
- Repository: https://github.com/vincent-agi/microservices

## 📄 Licence

Projet privé et propriétaire
