FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Install dependencies (use package-lock for reproducible installs)
COPY package*.json ./
RUN npm ci --only=production

# Copy app source
COPY . .

# Expose the port the app listens on
EXPOSE 3000

# Start the application
CMD ["node", "server.js"]
