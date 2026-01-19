from flask import Flask, jsonify, render_template, request
import requests
from typing import Optional, Dict, Any
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt, get_jwt_identity, unset_jwt_cookies
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from datetime import datetime, timedelta, timezone
import env # import secrets

app = Flask(__name__)

# Configuration
app.config['JWT_SECRET_KEY'] = env.JWT_SECRET_KEY
app.config['SQLALCHEMY_DATABASE_URI'] = env.SQLALCHEMY_DATABASE_URI
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = timedelta(hours=1)

# Initialize Extensions
db = SQLAlchemy(app)
jwt = JWTManager(app)
bcrypt = Bcrypt(app)

# User Model
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)

    def __repr__(self):
        return f'<User {self.username}>'

# Create tables
with app.app_context():
    db.create_all()

API_BASE_URL = env.API_BASE_URL
API_KEY = env.API_KEY

class PetStoreAPI:
    """Client for interacting with the Petstore API"""
    
    def __init__(self, base_url: str, api_key: str):
        self.base_url = base_url
        self.api_key = api_key
        self.headers = {
            'accept': 'application/json',
            'api_key': self.api_key
        }
    
    def get_pet_by_id(self, pet_id: int) -> Dict[str, Any]:
        """Get pet details by ID"""
        url = f"{self.base_url}/pet/{pet_id}"
        response = requests.get(url, headers=self.headers)
        response.raise_for_status()
        return response.json()
    
    def find_pets_by_status(self, status: str = "available") -> list:
        """Find pets by status (available, pending, sold)"""
        url = f"{self.base_url}/pet/findByStatus"
        params = {'status': status}
        response = requests.get(url, headers=self.headers, params=params)
        response.raise_for_status()
        return response.json()

# Initialize API client
pet_api = PetStoreAPI(API_BASE_URL, API_KEY)

@app.route('/')
def index():
    """Home page with API documentation"""
    return render_template('index.html')
# /api/v1/
# /api/
@app.route('/api/pet/<int:pet_id>')
def get_pet(pet_id: int):
    """Endpoint to get pet by ID"""
    try:
        pet_data = pet_api.get_pet_by_id(pet_id)
        return jsonify({
            'success': True,
            'data': pet_data
        })
    except requests.exceptions.HTTPError as e:
        return jsonify({
            'success': False,
            'error': str(e),
            'status_code': e.response.status_code
        }), e.response.status_code
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/pets/status/<status>')
def get_pets_by_status(status: str):
    """Endpoint to find pets by status"""
    try:
        pets = pet_api.find_pets_by_status(status)
        return jsonify({
            'success': True,
            'count': len(pets),
            'data': pets
        })
    except requests.exceptions.HTTPError as e:
        return jsonify({
            'success': False,
            'error': str(e),
            'status_code': e.response.status_code
        }), e.response.status_code
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

# Authentication Endpoints

@app.route('/api/register', methods=['POST'])
def register():
    """Register a new user"""
    try:
        data = request.get_json()
        if not data:
            return jsonify({"message": "No input data provided"}), 400
            
        username = data.get('username')
        password = data.get('password')
        
        if not username or not password:
            return jsonify({"message": "Username and password are required"}), 400
            
        if User.query.filter_by(username=username).first():
            return jsonify({"message": "Username already exists"}), 409
            
        hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')
        new_user = User(username=username, password=hashed_password)
        
        db.session.add(new_user)
        db.session.commit()
        
        return jsonify({"message": "User created successfully", "user_id": new_user.id}), 201
        
    except Exception as e:
        return jsonify({"message": "Registration failed", "error": str(e)}), 500

@app.route('/api/login', methods=['POST'])
def login():
    """Login and return JWT token"""
    try:
        data = request.get_json()
        if not data:
            return jsonify({"message": "No input data provided"}), 400
            
        username = data.get('username')
        password = data.get('password')
        
        if not username or not password:
            return jsonify({"message": "Username and password are required"}), 400
            
        user = User.query.filter_by(username=username).first()
        
        if user and bcrypt.check_password_hash(user.password, password):
            access_token = create_access_token(identity=str(user.id))
            return jsonify({
                "message": "Login successful",
                "access_token": access_token
            }), 200
            
        return jsonify({"message": "Invalid credentials"}), 401
        
    except Exception as e:
        return jsonify({"message": "Login failed", "error": str(e)}), 500

@app.route('/api/logout', methods=['POST'])
def logout():
    """Logout (client-side usually handles token removal, but this is a placeholder for blacklist)"""
    response = jsonify({"message": "Logout successful"})
    unset_jwt_cookies(response)
    return response, 200


@app.route('/api/test')
@jwt_required()
def test_api():
    """Test endpoint to verify API connectivity"""
    try:
        pet_data = pet_api.get_pet_by_id(1)
        return jsonify({
            'success': True,
            'message': 'API connection successful',
            'sample_data': pet_data
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'message': 'API connection failed',
            'error': str(e)
        }), 500

## additional API endpoints 
@app.route('/api/user/<int:user_id>')
def get_user(user_id: int):
    """Endpoint to get user by ID"""
    try:
        user_data = pet_api.get_user_by_id(user_id)
        return jsonify({
            'success': True,
            'data': user_data
        })
    except requests.exceptions.HTTPError as e:
        return jsonify({
            'success': False,
            'error': str(e),
            'status_code': e.response.status_code
        }), e.response.status_code
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/store/inventory')
def get_inventory():
    """Endpoint to get inventory"""
    try:
        inventory = pet_api.get_inventory()
        return jsonify({
            'success': True,
            'data': inventory
        })
    except requests.exceptions.HTTPError as e:
        return jsonify({
            'success': False,
            'error': str(e),
            'status_code': e.response.status_code
        }), e.response.status_code
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)

