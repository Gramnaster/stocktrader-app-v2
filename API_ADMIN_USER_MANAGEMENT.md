# Admin User Management API Documentation

## Overview
This document describes the complete CRUD API endpoints for admin user management in the Stock Trader application.

## Authentication
All endpoints require admin authentication. Include JWT token in Authorization header:
```
Authorization: Bearer <jwt_token>
```

## Base URL
All endpoints are prefixed with: `/api/v1/users`

---

## 1. List All Users
**GET** `/api/v1/users`

Lists all users in the system with their complete details including country and wallet information.

### Response
```json
[
  {
    "id": 1,
    "email": "user@example.com",
    "first_name": "John",
    "middle_name": "Michael",
    "last_name": "Doe",
    "date_of_birth": "1990-01-01",
    "mobile_no": "1234567890",
    "address_line_01": "123 Main St",
    "address_line_02": "Apt 4B",
    "city": "New York",
    "zip_code": "10001",
    "country_id": 1,
    "user_status": "approved",
    "user_role": "trader",
    "created_at": "2025-09-30T12:00:00.000Z",
    "updated_at": "2025-09-30T12:00:00.000Z",
    "confirmed_at": "2025-09-30T12:00:00.000Z",
    "country": {
      "id": 1,
      "name": "United States",
      "code": "US"
    },
    "wallet": {
      "id": 1,
      "balance": 10000.0
    }
  }
]
```

---

## 2. Get Single User
**GET** `/api/v1/users/:id`

Retrieves detailed information for a specific user.

### Response
Same structure as individual user object in list endpoint.

---

## 3. Create New User
**POST** `/api/v1/users`

Creates a new user account. Admin-created users are automatically confirmed.

### Request Body
```json
{
  "user": {
    "email": "newuser@example.com",
    "first_name": "Jane",
    "middle_name": "Elizabeth",
    "last_name": "Smith",
    "date_of_birth": "1985-06-15",
    "mobile_no": "9876543210",
    "address_line_01": "456 Oak Ave",
    "address_line_02": "Suite 201",
    "city": "Los Angeles",
    "zip_code": "90210",
    "country_id": 1,
    "user_role": "trader",
    "user_status": "approved"
  },
  "password": "SecurePassword123!",
  "password_confirmation": "SecurePassword123!"
}
```

### Response (201 Created)
```json
{
  "message": "User created successfully",
  "user": {
    // Same structure as show endpoint
  }
}
```

### Field Descriptions
- **email**: Must be unique, valid email format
- **user_role**: `"trader"` or `"admin"`
- **user_status**: `"pending"`, `"approved"`, or `"rejected"`
- **country_id**: Must reference existing Country record
- **password**: Minimum 6 characters (required for creation)

---

## 4. Update User
**PUT/PATCH** `/api/v1/users/:id`

Updates an existing user's information. Can update any field including password.

### Request Body (All fields optional)
```json
{
  "user": {
    "email": "updated@example.com",
    "first_name": "Updated",
    "last_name": "Name",
    "mobile_no": "1111111111",
    "user_status": "approved",
    "user_role": "admin"
  },
  "password": "NewPassword123!",
  "password_confirmation": "NewPassword123!"
}
```

### Response (200 OK)
```json
{
  "message": "User updated successfully",
  "user": {
    // Updated user object
  }
}
```

---

## 5. Delete User
**DELETE** `/api/v1/users/:id`

Permanently deletes a user account.

### Response (200 OK)
```json
{
  "message": "User deleted successfully"
}
```

---

## 6. Update User Status
**PATCH** `/api/v1/users/:id/update_status`

Quick endpoint specifically for updating user approval status.

### Request Body
```json
{
  "user_status": "approved"
}
```

### Response
```json
{
  "message": "User status updated successfully",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "user_status": "approved",
    "updated_at": "2025-09-30T12:00:00.000Z"
  }
}
```

---

## Error Responses

### 401 Unauthorized
```json
{
  "error": "Access denied. Admin privileges required."
}
```

### 404 Not Found
```json
{
  "error": "User not found"
}
```

### 422 Unprocessable Entity
```json
{
  "errors": [
    "Email has already been taken",
    "Password is too short (minimum is 6 characters)"
  ]
}
```

---

## Usage Examples for React-Vite Frontend

### Fetch All Users
```javascript
const fetchUsers = async () => {
  const response = await fetch('/api/v1/users', {
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    }
  });
  return response.json();
};
```

### Create New User
```javascript
const createUser = async (userData) => {
  const response = await fetch('/api/v1/users', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      user: userData,
      password: userData.password,
      password_confirmation: userData.passwordConfirmation
    })
  });
  return response.json();
};
```

### Update User
```javascript
const updateUser = async (userId, userData) => {
  const response = await fetch(`/api/v1/users/${userId}`, {
    method: 'PATCH',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ user: userData })
  });
  return response.json();
};
```

### Filter Pending Users (Frontend)
```javascript
const pendingUsers = users.filter(user => user.user_status === 'pending');
```

---

## Notes

1. **Auto-confirmation**: Admin-created users bypass email confirmation
2. **Wallet Creation**: Wallets are automatically created for new users
3. **Password Updates**: Include both `password` and `password_confirmation` fields
4. **Validation**: All Devise and custom validations apply
5. **Associations**: Country must exist before assigning to user
6. **Security**: All endpoints require admin role authentication