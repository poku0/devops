# Stage 1: build the React app
FROM node:18-alpine AS build

WORKDIR /app

# Install dependencies (use package-lock.json when present)
COPY package*.json ./
RUN npm ci

# Copy source and build
COPY . .
RUN npm run build

# Stage 2: serve with nginx
FROM nginx:alpine

# Remove default nginx content and copy build
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80 (map to host 3001 in docker-compose examples)
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
