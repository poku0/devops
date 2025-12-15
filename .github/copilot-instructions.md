<!-- Copilot instructions for the devops repo -->
# Repo-specific Copilot Instructions

Purpose: give an AI coding agent the essential, actionable context to be productive in this repository.

- **Quick architecture**: this workspace contains small Docker-based full-stack demo projects. The important components you will see repeatedly are:
  - Frontend: React app (see `22/user-ft/frontend/package.json` and `16/user-forms-ft/frontend/`)
  - Backend: Node/Express API (see `22/user-ft/backend/server.js`, `22/user-ft/backend/package.json`)
  - Database: MySQL (docker-compose services use `mysql:8` in `16/user-forms-ft/docker-compose.yml`)

- **Key integration points & patterns**:
  - Backends use `mysql2` and expect DB connection via env vars: `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` (defaults in `server.js` use `host: process.env.DB_HOST || "db"`).
  - Service hostnames in compose are service names (e.g. use `db` or `mysql` as DB host inside containers). See `16/user-forms-ft/docker-compose.yml` for examples.
  - Frontend is a standard Create‑React‑App project; the build output is `build/` and should be served by Nginx in production images (multi-stage Dockerfile pattern).

- **Ports to know**:
  - Backend: `3000` (server listens on 3000 in `22/user-ft/backend/server.js`)
  - Frontend (served by nginx in compose): host `3001` → container `80` in the example compose
  - MySQL: container `3306`, host mapped to `3307` in `16/user-forms-ft/docker-compose.yml`

- **Repo-specific gotchas & conventions**:
  - The backend `package.json` in `22/user-ft/backend/` has no `start` script; Dockerfiles or run instructions should call `node server.js` (or add a `start` script). An agent changing runtime should update `package.json` or Dockerfiles consistently.
  - `server.js` uses `appdb` as a default DB name while many compose examples use `testdb`. When modifying/creating compose files, align `DB_NAME` to avoid mismatches.
  - Database initialization: this backend exposes endpoints to initialize DB and table: `POST /dbinit` and `POST /tbinit` — useful for testing without rebuilding DB images.

- **Common commands / workflows** (run from the folder that contains the `docker-compose.yml` you want to use):
  - Build & start services: `docker-compose up --build`
  - Shut down: `docker-compose down`
  - Real example (from `16/user-forms-ft/`):
    - `cd 16/user-forms-ft && docker-compose up --build`
  - Manually initialize DB via backend (after backend is running):
    - `curl -X POST http://localhost:3000/dbinit`
    - `curl -X POST http://localhost:3000/tbinit`

- **Where to look for examples**:
  - Compose and env examples: `16/user-forms-ft/docker-compose.yml`
  - Backend code & env defaults: `22/user-ft/backend/server.js`, `22/user-ft/backend/package.json`
  - Frontend scripts: `22/user-ft/frontend/package.json` and `22/user-ft/frontend/build/` (prebuilt assets included in repo)
  - DB init SQL (when present): `16/user-forms-ft/script.sql`

- **Actionable guidance for agents**:
  - When adding or modifying Dockerfiles, follow the multi-stage pattern used for frontends: build with Node, serve static with Nginx (see README in `16/user-forms-ft/`).
  - Prefer changing `package.json` to add a `start` script for predictable container runtime (`"start": "node server.js"`) rather than requiring ad-hoc `docker run node server.js` commands.
  - If you change DB defaults, update both compose env entries and `server.js` defaults to avoid surprises.
  - Use the provided `/dbinit` and `/tbinit` endpoints to verify DB connectivity during iterative development.

- **Testing & verification tips**:
  - After changes, run `docker-compose up --build` in the relevant demo folder and confirm:
    - Backend logs show `Server running on port 3000` and `Connected to the database`.
    - Frontend is reachable at `http://localhost:3001` (if compose maps host port 3001).
  - Use `docker ps` and `docker logs <container>` to inspect containers.

If any section is unclear or you'd like more examples drawn from other subfolders, tell me which area to expand and I will iterate.
