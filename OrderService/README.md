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

## Schema Base de donnees

<img width="1600" height="530" alt="image" src="https://github.com/user-attachments/assets/80535685-8b96-4151-9f0a-2061e8de8714" />



```sql
-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: db
-- Generation Time: Dec 09, 2025 at 03:44 PM
-- Server version: 8.0.44
-- PHP Version: 8.3.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `order_database`
--

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` bigint NOT NULL,
  `order_number` varchar(50) NOT NULL,
  `user_id` int NOT NULL,
  `shipping_address` varchar(300) NOT NULL,
  `billing_address` varchar(300) NOT NULL,
  `total_amount` decimal(15,2) NOT NULL,
  `status` enum('CREATED','PAID','PREPARING','SHIPPED','DELIVERED','CANCELLED') NOT NULL DEFAULT 'CREATED',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `order_number` (`order_number`),
  ADD KEY `idx_orders_user_id` (`user_id`),
  ADD KEY `idx_orders_status` (`status`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
```
