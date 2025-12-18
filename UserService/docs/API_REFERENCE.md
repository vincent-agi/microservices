# UserService REST API - Quick Reference

## Base URL
```
http://localhost:3000
```

## Endpoints

### 1. Create User
**POST** `/users`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123",
  "firstName": "Jean",
  "lastName": "Dupont",
  "phone": "+33 6 12 34 56 78"
}
```

**Response (201):**
```json
{
  "data": {
    "id": 1,
    "email": "user@example.com",
    "firstName": "Jean",
    "lastName": "Dupont",
    "phone": "+33 6 12 34 56 78",
    "isActive": true,
    "createdAt": "2024-12-18T20:00:00.000Z",
    "updatedAt": "2024-12-18T20:00:00.000Z",
    "roles": []
  },
  "meta": {
    "timestamp": "1702929600000"
  }
}
```

### 2. List Users (with pagination)
**GET** `/users?page=1&limit=20`

**Query Parameters:**
- `page` (optional): Page number, default 1
- `limit` (optional): Items per page (1-100), default 20

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "email": "user@example.com",
      "firstName": "Jean",
      "lastName": "Dupont",
      "phone": "+33 6 12 34 56 78",
      "isActive": true,
      "createdAt": "2024-12-18T20:00:00.000Z",
      "updatedAt": "2024-12-18T20:00:00.000Z",
      "roles": []
    }
  ],
  "meta": {
    "timestamp": "1702929600000",
    "page": 1,
    "limit": 20,
    "total": 1,
    "totalPages": 1
  }
}
```

### 3. Get User by ID
**GET** `/users/{id}`

**Response (200):**
```json
{
  "data": {
    "id": 1,
    "email": "user@example.com",
    "firstName": "Jean",
    "lastName": "Dupont",
    "phone": "+33 6 12 34 56 78",
    "isActive": true,
    "createdAt": "2024-12-18T20:00:00.000Z",
    "updatedAt": "2024-12-18T20:00:00.000Z",
    "roles": []
  },
  "meta": {
    "timestamp": "1702929600000"
  }
}
```

### 4. Update User
**PUT** `/users/{id}`

**Request Body (all fields optional):**
```json
{
  "firstName": "Jean-Pierre",
  "lastName": "Martin",
  "phone": "+33 6 98 76 54 32",
  "isActive": false,
  "email": "newemail@example.com",
  "password": "NewPassword123"
}
```

**Response (200):**
```json
{
  "data": {
    "id": 1,
    "email": "newemail@example.com",
    "firstName": "Jean-Pierre",
    "lastName": "Martin",
    "phone": "+33 6 98 76 54 32",
    "isActive": false,
    "createdAt": "2024-12-18T20:00:00.000Z",
    "updatedAt": "2024-12-18T20:15:00.000Z",
    "roles": []
  },
  "meta": {
    "timestamp": "1702930500000"
  }
}
```

### 5. Delete User (Soft Delete)
**DELETE** `/users/{id}`

**Response (204):**
No content

## Error Responses

All errors follow this format:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {
      "field": "fieldName",
      "constraint": "constraintViolated"
    }
  }
}
```

### Common Error Codes:

| HTTP Status | Error Code | Description |
|------------|------------|-------------|
| 400 | BAD_REQUEST | Invalid request parameters |
| 400 | VALIDATION_ERROR | Input validation failed |
| 404 | NOT_FOUND | Resource not found |
| 409 | CONFLICT | Resource conflict (e.g., duplicate email) |
| 500 | INTERNAL_SERVER_ERROR | Server error |

### Example Error Response:

**404 Not Found:**
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "User with ID 999 not found",
    "details": {}
  }
}
```

**409 Conflict:**
```json
{
  "error": {
    "code": "CONFLICT",
    "message": "Email already exists",
    "details": {}
  }
}
```

**400 Validation Error:**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "fields": [
        "Email must be a valid email address",
        "Password must be at least 8 characters long"
      ]
    }
  }
}
```

## Testing with curl

### Create a user:
```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Password123",
    "firstName": "Test",
    "lastName": "User"
  }'
```

### List users:
```bash
curl http://localhost:3000/users?page=1&limit=10
```

### Get user by ID:
```bash
curl http://localhost:3000/users/1
```

### Update user:
```bash
curl -X PUT http://localhost:3000/users/1 \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Updated Name"
  }'
```

### Delete user:
```bash
curl -X DELETE http://localhost:3000/users/1
```

## Notes

- All passwords are hashed with bcrypt before storage
- `passwordHash` field is never returned in responses
- Soft delete is used - records are not physically deleted
- All timestamps are in milliseconds (Unix epoch)
- Pagination is mandatory for list endpoints
- All endpoints return JSON with `data` and `meta` structure
