# Environnement de développement Docker avec Java Spring boot + MySQL + phpMyAdmin

## structure du projet

```txt
spring-app/
│
├── src/
│   ├── main/
│   │    ├── java/com/example/demo/
│   │    │     └── HelloController.java
│   │    └── resources/
│   │          └── application.properties
│   └── test/
│
├── pom.xml
│
├── Dockerfile.dev
├── docker-compose.yml
├── .env
└── README.md
```

## Caractèristiques

- Java Spring boot avec hot reload
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

| Service         | URL                                            |
| --------------- | ---------------------------------------------- |
| API Spring Boot | [http://localhost:8080](http://localhost:8080) |
| phpMyAdmin      | [http://localhost:8084](http://localhost:8084) |
| MySQL           | localhost:3306                                 |


## Voir les informations dans la base de données (phpMyAdmin)

Lien : [http://localhost:8084](http://localhost:8084)


| Champ        | Valeur |
| ------------ | ------ |
| Serveur      | order-db     |
| Utilisateur  | order_db_user   |
| Mot de passe | order_password    |

La base `order_database` existe déjà.

## Le code du microservice

Tout le code de votre microservice doit se trouver dans le dossier `src/`

## Vérifier fonctionnement minimal microsevice

Cliquez ici : [http://localhost:8080/hello](http://localhost:8080/hello)

## Ajouter des dépednances au projet Java

Ajouter les dépendances dans ce fichier `pom.xml`

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

## Exemple rapide code Spring boot

Le but est de tester l'API rapidement

```Java
package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    @GetMapping("/hello")
    public String hello() {
        return "Hello from Spring Boot on Docker!";
    }
}
```