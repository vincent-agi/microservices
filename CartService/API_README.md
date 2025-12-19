# CartService - REST API Implementation

## Overview
This is a complete REST API implementation for the CartService microservice, part of a microservices-based e-commerce platform. The service manages shopping carts (paniers) and cart items (articles) with full CRUD operations.

## Quick Start

### Start the service
```bash
cd CartService
docker compose up --build
```

### Access Points
- **API**: http://localhost:5001
- **phpMyAdmin**: http://localhost:8082
- **MySQL**: localhost:3307

## Architecture

### Project Structure
```
CartService/
├── app/
│   ├── main.py                      # Flask application entry point
│   ├── config/
│   │   ├── __init__.py
│   │   └── database.py              # Database configuration
│   ├── models/
│   │   ├── __init__.py
│   │   ├── panier.py                # Panier (Cart) entity
│   │   └── article.py               # Article (Cart Item) entity
│   ├── services/
│   │   ├── __init__.py
│   │   ├── panier_service.py        # Panier business logic
│   │   └── article_service.py       # Article business logic
│   ├── controllers/
│   │   ├── __init__.py
│   │   ├── panier_controller.py     # Panier REST endpoints
│   │   └── article_controller.py    # Article REST endpoints
│   └── utils/
│       ├── __init__.py
│       ├── responses.py             # Response formatting
│       ├── validation.py            # Input validation
│       └── user_service.py          # UserService integration
├── documentation_metier.md          # Business documentation (French)
├── requirements.txt                 # Python dependencies
├── .env                            # Environment variables
├── docker-compose.yml              # Docker configuration
└── Dockerfile.dev                  # Development Dockerfile
```

## API Endpoints

### Panier (Shopping Cart) Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/paniers` | Create a new panier |
| GET | `/paniers` | List all paniers (with pagination) |
| GET | `/paniers/{id}` | Get panier by ID with articles |
| PUT | `/paniers/{id}` | Update a panier |
| DELETE | `/paniers/{id}` | Delete a panier |
| GET | `/paniers/user/{userId}` | Get all paniers for a user |

### Article (Cart Item) Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/articles` | Add article to panier |
| GET | `/articles` | List all articles (with pagination) |
| GET | `/articles/{id}` | Get article by ID |
| PUT | `/articles/{id}` | Update an article |
| DELETE | `/articles/{id}` | Delete an article |
| GET | `/articles/panier/{panierId}` | Get all articles in a panier |

### Health Check Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/hello` | Simple health check |
| GET | `/health` | Service status |

## Example Requests

### Create a Panier
```bash
curl -X POST http://localhost:5001/paniers \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "status": "active"
  }'
```

**Response:**
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

### Add Article to Panier
```bash
curl -X POST http://localhost:5001/articles \
  -H "Content-Type: application/json" \
  -d '{
    "panierId": 1,
    "productId": "PROD-123",
    "quantity": 2,
    "unitPrice": 29.99
  }'
```

**Response:**
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

### Get Panier with Articles
```bash
curl http://localhost:5001/paniers/1
```

**Response:**
```json
{
  "data": {
    "idPanier": 1,
    "dateCreation": "2024-12-19T10:00:00.000Z",
    "dateModification": null,
    "status": "active",
    "userId": 1,
    "articles": [
      {
        "idArticle": 1,
        "panierId": 1,
        "productId": "PROD-123",
        "quantity": 2,
        "unitPrice": 29.99,
        "totalLine": 59.98,
        "createdAt": "2024-12-19T10:05:00.000Z"
      }
    ],
    "totalQuantity": 2,
    "totalPrice": 59.98
  },
  "meta": {
    "timestamp": 1734602800000
  }
}
```

### List Paniers with Pagination
```bash
curl "http://localhost:5001/paniers?page=1&limit=20&userId=1&status=active"
```

## Response Format

All responses follow a standardized format as defined in `standardisation_api_rest.md`:

### Success Response
```json
{
  "data": { /* Response data */ },
  "meta": {
    "timestamp": 1734602400000,
    "page": 1,          // For paginated responses
    "limit": 20,        // For paginated responses
    "total": 100,       // For paginated responses
    "totalPages": 5     // For paginated responses
  }
}
```

### Error Response
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {
      "field": "fieldName"
    }
  }
}
```

## Database Schema

### Table: `panier`
```sql
CREATE TABLE panier (
  id_panier INT PRIMARY KEY AUTO_INCREMENT,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
  status VARCHAR(50),
  user_id INT
);
```

### Table: `article`
```sql
CREATE TABLE article (
  id_article INT PRIMARY KEY AUTO_INCREMENT,
  panier_id INT NOT NULL,
  product_id VARCHAR(255) NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  total_line DECIMAL(10,2) AS (quantity * unit_price) STORED,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (panier_id) REFERENCES panier(id_panier) ON DELETE CASCADE
);
```

## Features

### Business Features
- ✅ Create and manage shopping carts
- ✅ Add/update/remove articles in carts
- ✅ Automatic calculation of line totals and cart totals
- ✅ User association with carts
- ✅ Cart status management (active, completed, abandoned)
- ✅ Pagination for all list operations

### Technical Features
- ✅ SQLAlchemy ORM with MySQL
- ✅ RESTful API design
- ✅ Standardized JSON responses (camelCase)
- ✅ Proper HTTP status codes
- ✅ Input validation
- ✅ Error handling
- ✅ UserService integration
- ✅ Database cascade deletes
- ✅ Computed columns for totals
- ✅ PyDoc documentation

## Standards Compliance

This API follows all standards defined in `standardisation_api_rest.md`:

- ✅ Resource-oriented endpoints with plural nouns
- ✅ No verbs in URLs
- ✅ JSON format with camelCase
- ✅ Standardized responses with `data` and `meta`
- ✅ Proper HTTP status codes (200, 201, 204, 400, 404, 500)
- ✅ Normalized error format
- ✅ Pagination with `page` and `limit`
- ✅ Timestamp in milliseconds (integer)
- ✅ PyDoc documentation throughout

## Environment Variables

Configuration is managed through `.env` file:

```env
DB_HOST=db
DB_USER=root
DB_PASSWORD=root
DB_NAME=cart_db
USER_SERVICE_URL=http://user-api:3000
FLASK_ENV=development
```

## Integration with Other Services

### UserService
The CartService validates users by calling the UserService:
- URL: `http://user-api:3000/users/{id}`
- Used when creating/updating paniers with userId
- Returns appropriate error if user doesn't exist

### Future: OrderService
When a panier is completed, it can be sent to OrderService to create an order.

## Technologies

- **Flask** 3.0+ - Web framework
- **SQLAlchemy** 2.0+ - ORM
- **MySQL** 8.0 - Database
- **mysql-connector-python** - MySQL driver
- **requests** 2.31+ - HTTP client
- **python-dotenv** - Environment management

## Development

### Install Dependencies
```bash
pip install -r requirements.txt
```

### Run Locally (without Docker)
```bash
cd app
python main.py
```

### Run with Docker
```bash
docker compose up --build
```

### Access phpMyAdmin
- URL: http://localhost:8082
- Server: db
- Username: root
- Password: root

## Testing

The implementation has been tested with:
- ✅ Import verification
- ✅ Model instantiation
- ✅ Response format validation
- ✅ Pagination utilities
- ✅ Error handling
- ✅ API endpoint registration

## Security

- ✅ SQL injection prevention via SQLAlchemy ORM
- ✅ Input validation for all parameters
- ✅ User ID validation before HTTP requests
- ✅ Flask debug mode controlled by environment variable
- ✅ No hardcoded credentials
- ✅ CodeQL security scan passed

## Documentation

Complete business documentation is available in French:
- **File**: `documentation_metier.md`
- **Contents**:
  - Business domain overview
  - Entity descriptions
  - API endpoint details with examples
  - Use cases
  - Error handling
  - Integration patterns
  - Database schema
  - Architecture overview

## Team

- **Microservice**: CartService (Flask/Python)
- **Team Members**: Imane & Jonathan
- **Repository**: https://github.com/vincent-agi/microservices

## Notes

- String type used for status field (not enum as requested for simplicity)
- Computed column (total_line) calculated at database level
- Cascade delete ensures articles are removed when panier is deleted
- All timestamps use UTC timezone
- Pagination maximum limit is 100 items per page
- Database initialization is deferred to first request
