# Flask REST API with JWT Authentication and Swagger Documentation

A simple Flask REST API with JWT token-based authentication, multiple endpoints, and Swagger/OpenAPI documentation.

## Features

- JWT Authentication (Register, Login, Logout)
- Protected and Public Routes
- Swagger UI Documentation
- Token Blacklist for Logout
- Password Hashing with bcrypt
- RESTful API Design

## Tech Stack

- **Flask** - Web framework
- **Flask-JWT-Extended** - JWT authentication
- **Flask-RESTX** - Swagger/OpenAPI documentation
- **Flask-Bcrypt** - Password hashing
- **SQLite** - Database (easily replaceable with PostgreSQL/MySQL)

## Installation

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd flask-jwt-api
```

### 2. Create virtual environment

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Set environment variables

Create a `.env` file:

```bash
SECRET_KEY=your-secret-key-here-change-in-production
JWT_SECRET_KEY=your-jwt-secret-key-here-change-in-production
DATABASE_URL=sqlite:///app.db
```

### 5. Initialize database

```bash
python init_db.py
```

### 6. Run the application

```bash
python app.py
```

The API will be available at `http://localhost:5000`

Swagger documentation: `http://localhost:5000/swagger`

## API Endpoints

### Authentication Endpoints

#### Register New User
```http
POST /api/auth/register
Content-Type: application/json

{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "SecurePass123"
}
```

**Response:**
```json
{
  "message": "User registered successfully",
  "user_id": 1
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "SecurePass123"
}
```

**Response:**
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {
    "id": 1,
    "username": "john_doe",
    "email": "john@example.com"
  }
}
```

#### Logout
```http
POST /api/auth/logout
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "message": "Successfully logged out"
}
```

#### Refresh Token
```http
POST /api/auth/refresh
Authorization: Bearer <refresh_token>
```

**Response:**
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

### User Endpoints

#### Get Current User Profile
```http
GET /api/users/me
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "id": 1,
  "username": "john_doe",
  "email": "john@example.com",
  "created_at": "2025-01-19T10:30:00"
}
```

#### Update User Profile
```http
PUT /api/users/me
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "username": "new_username"
}
```

#### Get All Users (Admin only)
```http
GET /api/users
Authorization: Bearer <access_token>
```

### Product Endpoints (Example CRUD)

#### Get All Products
```http
GET /api/products
```

**Response:**
```json
{
  "products": [
    {
      "id": 1,
      "name": "Laptop",
      "description": "High performance laptop",
      "price": 999.99,
      "stock": 50
    }
  ],
  "total": 1
}
```

#### Get Product by ID
```http
GET /api/products/1
```

#### Create Product (Protected)
```http
POST /api/products
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "name": "Smartphone",
  "description": "Latest model smartphone",
  "price": 699.99,
  "stock": 100
}
```

#### Update Product (Protected)
```http
PUT /api/products/1
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "price": 899.99,
  "stock": 75
}
```

#### Delete Product (Protected)
```http
DELETE /api/products/1
Authorization: Bearer <access_token>
```

### Order Endpoints

#### Create Order (Protected)
```http
POST /api/orders
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "items": [
    {
      "product_id": 1,
      "quantity": 2
    }
  ]
}
```

#### Get User Orders (Protected)
```http
GET /api/orders/my-orders
Authorization: Bearer <access_token>
```

#### Get Order by ID (Protected)
```http
GET /api/orders/1
Authorization: Bearer <access_token>
```

### Category Endpoints

#### Get All Categories
```http
GET /api/categories
```

#### Create Category (Protected)
```http
POST /api/categories
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "name": "Electronics",
  "description": "Electronic devices and accessories"
}
```

## Project Structure

```
flask-jwt-api/
│
├── app.py                 # Main application file
├── config.py              # Configuration settings
├── init_db.py            # Database initialization script
├── requirements.txt       # Python dependencies
├── .env                  # Environment variables (create this)
├── README.md             # This file
│
├── models/
│   ├── __init__.py
│   ├── user.py           # User model
│   ├── product.py        # Product model
│   ├── order.py          # Order model
│   └── token_blacklist.py # Token blacklist model
│
├── routes/
│   ├── __init__.py
│   ├── auth.py           # Authentication routes
│   ├── users.py          # User routes
│   ├── products.py       # Product routes
│   ├── orders.py         # Order routes
│   └── categories.py     # Category routes
│
└── utils/
    ├── __init__.py
    ├── validators.py     # Input validation
    └── decorators.py     # Custom decorators
```

## JWT Authentication Flow

### 1. **Registration**
- User submits username, email, and password
- Password is hashed using bcrypt
- User data is stored in database
- Returns success message

### 2. **Login**
- User submits email and password
- Password is verified against hashed password
- JWT access token (expires in 15 min) and refresh token (expires in 30 days) are generated
- Tokens are returned to client

### 3. **Accessing Protected Routes**
- Client includes access token in Authorization header: `Bearer <token>`
- Server validates token
- If valid, request proceeds; if expired/invalid, returns 401 Unauthorized

### 4. **Token Refresh**
- When access token expires, client sends refresh token
- Server validates refresh token
- New access token is issued
- Client continues making requests

### 5. **Logout**
- Client sends logout request with access token
- Token is added to blacklist
- Future requests with that token are rejected

## Simple Code Example

### Minimal Flask App with JWT

```python
from flask import Flask, jsonify, request
from flask_jwt_extended import (
    JWTManager, create_access_token, 
    jwt_required, get_jwt_identity
)
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
app.config['JWT_SECRET_KEY'] = 'super-secret-key'
jwt = JWTManager(app)

# In-memory user storage (use database in production)
users = {}

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    
    if username in users:
        return jsonify({"error": "User already exists"}), 400
    
    users[username] = generate_password_hash(password)
    return jsonify({"message": "User registered successfully"}), 201

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    
    if username not in users or not check_password_hash(users[username], password):
        return jsonify({"error": "Invalid credentials"}), 401
    
    access_token = create_access_token(identity=username)
    return jsonify({"access_token": access_token}), 200

@app.route('/protected', methods=['GET'])
@jwt_required()
def protected():
    current_user = get_jwt_identity()
    return jsonify({"message": f"Hello {current_user}!"}), 200

if __name__ == '__main__':
    app.run(debug=True)
```

### Testing the Simple Example

```bash
# Register
curl -X POST http://localhost:5000/register \
  -H "Content-Type: application/json" \
  -d '{"username": "test", "password": "test123"}'

# Login
curl -X POST http://localhost:5000/login \
  -H "Content-Type: application/json" \
  -d '{"username": "test", "password": "test123"}'

# Access Protected Route
curl -X GET http://localhost:5000/protected \
  -H "Authorization: Bearer <your_token_here>"
```

## Security Best Practices

1. **Environment Variables**: Never commit `.env` file with real secrets
2. **Password Hashing**: Always hash passwords (bcrypt, argon2)
3. **Token Expiration**: Set appropriate expiration times
4. **HTTPS**: Always use HTTPS in production
5. **Token Blacklist**: Implement logout with token blacklisting
6. **Input Validation**: Validate and sanitize all user inputs
7. **Rate Limiting**: Implement rate limiting to prevent brute force attacks
8. **CORS**: Configure CORS properly for frontend access

## Common Issues & Solutions

### Issue: "Token has expired"
**Solution**: Use refresh token endpoint to get new access token

### Issue: "Invalid token"
**Solution**: Ensure token is included in Authorization header as `Bearer <token>`

### Issue: "Unable to decode token"
**Solution**: Check JWT_SECRET_KEY matches between token creation and validation

## Testing with Postman/Thunder Client

1. **Register**: POST to `/api/auth/register` with user data
2. **Login**: POST to `/api/auth/login` to get tokens
3. **Copy Access Token**: From login response
4. **Protected Routes**: Add to Headers:
   - Key: `Authorization`
   - Value: `Bearer <paste_your_token>`

## Deployment

### Environment Variables for Production

```bash
SECRET_KEY=<generate-strong-random-key>
JWT_SECRET_KEY=<generate-strong-random-key>
DATABASE_URL=postgresql://user:pass@host:5432/dbname
FLASK_ENV=production
```

### Generate Secret Keys

```python
import secrets
print(secrets.token_hex(32))
```
