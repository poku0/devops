# Flask API Caller - Petstore Demo

A Flask application that demonstrates how to call external REST APIs, using the Petstore API as an example.

## Features

- 🔌 RESTful API integration with external services
- 🎨 Clean web interface for testing API calls
- 🛡️ Error handling and response validation
- 📝 Organized code structure with API client class
- 🧪 Multiple endpoint examples (GET by ID, GET by status)

## Project Structure

```
.
├── app.py                 # Main Flask application
├── requirements.txt       # Python dependencies
├── templates/
│   └── index.html        # Web interface
├── .env.example          # Environment variables template
└── README.md             # This file
```

## Installation

1. **Clone or navigate to the project directory**

2. **Create a virtual environment** (recommended):
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies**:
```bash
pip install -r requirements.txt
```

4. **Optional: Configure environment variables**:
```bash
cp .env.example .env
# Edit .env file if needed
```

## Running the Application

Start the Flask development server:

```bash
python app.py
```

The application will be available at `http://localhost:5000`

## API Endpoints

### Web Interface
- `GET /` - Interactive web interface for testing API calls

### API Routes
- `GET /api/pet/<pet_id>` - Get pet details by ID
  - Example: `http://localhost:5000/api/pet/1`

- `GET /api/pets/status/<status>` - Find pets by status
  - Status values: `available`, `pending`, `sold`
  - Example: `http://localhost:5000/api/pets/status/available`

- `GET /api/test` - Test API connectivity

## Usage Examples

### Using the Web Interface
1. Open `http://localhost:5000` in your browser
2. Enter a Pet ID or select a status
3. Click the button to make the API call
4. View the JSON response

### Using curl

**Get pet by ID:**
```bash
curl http://localhost:5000/api/pet/1
```

**Find pets by status:**
```bash
curl http://localhost:5000/api/pets/status/available
```

**Test connection:**
```bash
curl http://localhost:5000/api/test
```

### Using Python requests

```python
import requests

# Get pet by ID
response = requests.get('http://localhost:5000/api/pet/1')
print(response.json())

# Find pets by status
response = requests.get('http://localhost:5000/api/pets/status/available')
print(response.json())
```

## Customizing for Your Own API

To adapt this project for your own API:

1. **Update the API configuration** in `app.py`:
```python
API_BASE_URL = "https://your-api-url.com"
API_KEY = "your-api-key"
```

2. **Modify the API client class**:
   - Update the `PetStoreAPI` class methods
   - Add your own API endpoints
   - Adjust headers and authentication as needed

3. **Update Flask routes**:
   - Create new routes for your API endpoints
   - Update the response handling logic

4. **Customize the web interface** in `templates/index.html`

## Code Overview

### API Client Class
The `PetStoreAPI` class handles all API communication:
- Centralized configuration (base URL, API key, headers)
- Reusable methods for different endpoints
- Error handling with requests library

### Flask Routes
- Each route wraps an API client method
- Returns JSON responses with success/error status
- Includes proper HTTP status codes

### Error Handling
- Catches HTTP errors from the external API
- Returns appropriate error messages and status codes
- Handles network issues and timeouts

## Dependencies

- **Flask**: Web framework
- **requests**: HTTP library for API calls
- **python-dotenv**: Environment variable management

## Development Tips

1. **Enable debug mode** during development (already enabled in `app.py`)
2. **Use environment variables** for sensitive data (API keys, URLs)
3. **Add logging** for troubleshooting API calls
4. **Implement caching** for frequently accessed data
5. **Add request timeouts** to prevent hanging connections

## Security Considerations

- Never commit API keys to version control
- Use environment variables for sensitive configuration
- Implement rate limiting for production use
- Validate and sanitize user inputs
- Use HTTPS in production environments

## Next Steps

- Add POST/PUT/DELETE endpoints for creating/updating data
- Implement authentication and authorization
- Add request caching with Redis or Flask-Caching
- Create unit tests with pytest
- Add OpenAPI/Swagger documentation
- Implement async API calls with aiohttp

## License

MIT License - feel free to use this as a template for your own projects!

## Support

For issues or questions about the Petstore API, visit:
https://petstore.swagger.io
