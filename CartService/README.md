# Environnement de développement Docker avec Flask + MySQL + phpMyAdmin

## structure du projet

```txt
project/
│
├── app/
│   ├── main.py
│   └── __init__.py
│
├── Dockerfile.dev
├── docker-compose.yml
├── requirements-dev.txt
└── README.md
```

## Caractèristiques

- Flask avec hot reload
- MySQL préconfiguré
- phpMyAdmin pour visualiser la base

Code modifiable depuis VSCode sur votre machine

Prérequis :
- Docker Desktop installé
- VSCode conseillé mais autre éditeur de code OK

1. Démarrer tout l’environnement

Ouvre un terminal à la racine du projet :

```bash
docker compose up --build
```

## URL

| Service      | URL                                            |
| ------------ | ---------------------------------------------- |
| API Flask    | [http://localhost:5001](http://localhost:5001) |
| phpMyAdmin   | [http://localhost:8082](http://localhost:8082) |
| MySQL server | localhost:3306                                 |


## Voir les informations dans la base de données (phpMyAdmin)

Lien : [http://localhost:8082](http://localhost:8082)

| Champ        | Valeur |
| ------------ | ------ |
| Serveur      | db     |
| Utilisateur  | root   |
| Mot de passe | root   |

La base `mydb` existe déjà.

## Le code du microservice

Tout le code de votre microservice doit se trouver dans le dossier `app/`

## Vérifier fonctionnement minimal microsevice

Cliquez ici : [http://localhost:5001/hello](http://localhost:5001/hello)

## Ajouter des dépednances au projet Flask

Ajouter les dépendances dans ce fichier `requirements.txt`

et relancer

```bash
docker compose up --build
```

## Réinitialiser la base de données

> Attention cette action est définitive

```bash
docker compose down -v
docker compose up
```

## Variables d'environnement

Le fichier `.env` sert à stocker toutes les informations sensibles et les paramètres de configuration de l’application en dehors du code.

### Changer facilement la configuration

Si vous voulez changer :
- le mot de passe MySQL
- le nom de la base
- l’environnement (development / production)
- l’URL d’une API externe

Modifiez juste le `.env`dans votre microservice, pas le code.