# Docker Full-Stack Project Assignment 111

## Project Overview

You will containerize a full-stack application using Docker and Docker Compose. The application consists of three components that must work together:

- **Frontend**: React.js application
- **Backend**: Node.js/Express API server
- **Database**: MySQL database

## Your Tasks

You must create the following files:

1. **`backend/Dockerfile`** - Containerize the Node.js backend
2. **`frontend/Dockerfile`** - Containerize the React frontend (using multi-stage build)
3. **`docker-compose.yml`** - Orchestrate all three services

## Project Structure

```
docker-mysql-nodejs-reactjs-app/
├── backend/              # Node.js Express application
│   ├── package.json      # Backend dependencies and scripts
│   ├── server.js         # Main server file
│   └── Dockerfile        # ⚠️ YOU CREATE THIS
│
├── frontend/             # React.js application
│   ├── package.json      # Frontend dependencies and scripts
│   ├── src/              # React source code
│   └── Dockerfile        # ⚠️ YOU CREATE THIS
│
├── script.sql            # Database initialization script
└── docker-compose.yml    # ⚠️ YOU CREATE THIS
```

## Task 1: Backend Dockerfile

**File**: `backend/Dockerfile`

Create a Dockerfile that:
- Uses an appropriate Node.js base image
- Sets up a working directory
- Copies and installs dependencies efficiently
- Copies the application code
- Exposes the correct port
- Starts the application

### Where to Look:
- Check `backend/package.json` for:
  - Scripts section (how to start the app)
  - Dependencies
  - Node version requirements
- Check `backend/server.js` for:
  - Port configuration
  - Database connection details

##  Task 2: Frontend Dockerfile (Multi-Stage Build)

**File**: `frontend/Dockerfile`

Create a multi-stage Dockerfile that:

**Stage 1 - Build:**
- Uses Node.js to build the React application
- Installs dependencies
- Runs the build command

**Stage 2 - Serve:**
- Uses Nginx Alpine
- Copies built files from Stage 1
- Serves the application

### Where to Look:
- Check `frontend/package.json` for:
  - Build script
  - Output directory (usually `build/`)

### Why Multi-Stage?
Multi-stage builds create smaller, more efficient images by separating the build environment from the runtime environment.

## Task 3: Docker Compose File

**File**: `docker-compose.yml` (in project root)

Create a Docker Compose file that defines three services:

### Service 1: MySQL Database
- Use MySQL 8 image
- Set environment variables for database configuration
- Map ports correctly (host:3307 → container:3306)
- Create a volume for data persistence
- Mount `script.sql` to initialize the database

### Service 2: Backend (Node.js)
- Build from `./backend` directory
- Set environment variables for database connection
- **Important**: Use the MySQL service name as the database host
- Map port 3000
- Set dependency on MySQL service

### Service 3: Frontend (React)
- Build from `./frontend` directory
- Map port 3001 on host to port 80 in container
- Set dependency on backend service

### Additional Requirements:
- Create a custom network for service communication
- Create a named volume for MySQL data persistence

### Configuration Details You'll Need:

**Database Credentials:**
- Root password: `pass123`
- Database name: `testdb`
- User: `root`
- Port (inside container): `3306`
- Port (on host): `3307`

**Important Networking Note:**
- When backend connects to MySQL, use the **service name** (`mysql`) as the hostname, NOT `localhost`

## Requirements & Success Criteria

Your solution must:

1. **Build successfully**: All images build without errors
2. **Start successfully**: All containers start and stay running
3. **Network properly**: Backend can connect to MySQL, Frontend can call Backend
4. **Persist data**: Database data survives container restarts
5. **Be accessible**:
   - Frontend: http://localhost:3001
   - Backend: http://localhost:3000
   - MySQL: localhost:3307

## Testing Instructions

1. **Build and start**:
   ```bash
   docker-compose up --build
   ```

2. **Verify containers are running**:
   ```bash
   docker ps
   ```
   You should see 3 running containers

3. **Test the application**:
   - Open http://localhost:3001 in browser
   - Submit data through the form
   - Verify data is saved

4. **Test data persistence**:
   ```bash
   docker-compose down
   docker-compose up
   ```
   Data should still be present

## Submission Checklist

- [ ] `backend/Dockerfile` created
- [ ] `frontend/Dockerfile` created with multi-stage build
- [ ] `docker-compose.yml` created
- [ ] All containers start successfully
- [ ] Application is accessible at specified ports
- [ ] Data persists after container restart
- [ ] Can explain what each Dockerfile instruction does

## Research Topics

You will need to research and understand:

1. **Dockerfile Instructions**:
   - `FROM`, `WORKDIR`, `COPY`, `RUN`, `EXPOSE`, `CMD`
   - Multi-stage builds (`FROM ... AS stagename`)
   - `COPY --from=stagename`

2. **Docker Compose**:
   - Service definitions
   - Build contexts
   - Port mapping syntax
   - Environment variables
   - Volumes (named volumes vs bind mounts)
   - Networks
   - Service dependencies (`depends_on`)

3. **Best Practices**:
   - Why copy `package.json` separately?
   - Layer caching optimization
   - Using Alpine images
   - Multi-stage build benefits

## 💡 Hints

- Look at the `package.json` files to understand how to run each app
- The database host in backend should be the MySQL **service name** from docker-compose
- Nginx default port is 80
- MySQL default port is 3306 (inside container)
- Multi-stage builds use `COPY --from=build-stage`

---

**Good luck! 🐳**