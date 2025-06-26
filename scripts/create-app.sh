#!/bin/bash

# 🚀 Simple App Creator
# Creates a basic Node.js app with Docker

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

# Show help
show_help() {
    echo ""
    echo "🚀 Basic DevOps Toolkit - Create App"
    echo ""
    echo "Usage: $0 <app-name>"
    echo ""
    echo "Creates a new Node.js Express application with Docker support"
    echo ""
    echo "Example:"
    echo "  $0 my-awesome-app"
    echo ""
    echo "This will create:"
    echo "  • Express.js application"
    echo "  • Dockerfile for containerization"
    echo "  • docker-compose.yml for easy deployment"
    echo "  • Basic project structure"
    echo ""
}

# Check for help flag
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_help
    exit 0
fi

# Check if app name provided
if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage: $0 <app-name>${NC}"
    echo "Example: $0 my-awesome-app"
    show_help
    exit 1
fi

APP_NAME="$1"
APP_DIR="../$APP_NAME"

log "🚀 Creating app: $APP_NAME"

# Create app directory
if [ -d "$APP_DIR" ]; then
    echo -e "${YELLOW}Directory $APP_DIR already exists!${NC}"
    exit 1
fi

mkdir -p "$APP_DIR"
cd "$APP_DIR"

# Initialize git
log "📦 Initializing git..."
git init
git branch -M main

# Create package.json
log "📄 Creating package.json..."
cat > package.json << EOF
{
  "name": "$APP_NAME",
  "version": "1.0.0",
  "description": "Simple app created with Basic DevOps Toolkit",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "node index.js",
    "test": "echo \"No tests yet\" && exit 0"
  },
  "keywords": ["nodejs", "docker", "devops"],
  "author": "Basic DevOps Toolkit",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

# Create simple Express app
log "⚡ Creating Express app..."
cat > index.js << 'EOF'
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Basic middleware
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Main route
app.get('/', (req, res) => {
  res.json({
    message: `Welcome to ${process.env.npm_package_name || 'your app'}!`,
    version: process.env.npm_package_version || '1.0.0',
    environment: process.env.NODE_ENV || 'development'
  });
});

// API route
app.get('/api/info', (req, res) => {
  res.json({
    app: process.env.npm_package_name || 'your app',
    version: process.env.npm_package_version || '1.0.0',
    node: process.version,
    platform: process.platform,
    memory: process.memoryUsage(),
    uptime: process.uptime()
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Route not found',
    path: req.originalUrl
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`📖 API info: http://localhost:${PORT}/api/info`);
});
EOF

# Create Dockerfile
log "🐳 Creating Dockerfile..."
cat > Dockerfile << EOF
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy app source
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \\
    adduser -S -u 1001 -G nodejs nodejs

# Change ownership
RUN chown -R nodejs:nodejs /app
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \\
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Start app
CMD ["npm", "start"]
EOF

# Create docker-compose.yml
log "🔧 Creating docker-compose.yml..."
cat > docker-compose.yml << EOF
version: '3.8'

services:
  app:
    build: .
    container_name: ${APP_NAME}
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - PORT=3000
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
EOF

# Create .env.example
log "🔐 Creating .env.example..."
cat > .env.example << EOF
# Application
NODE_ENV=development
PORT=3000

# Add your environment variables here
EOF

# Create .gitignore
log "📝 Creating .gitignore..."
cat > .gitignore << EOF
# Dependencies
node_modules/
npm-debug.log*

# Environment variables
.env

# Logs
*.log

# OS files
.DS_Store
Thumbs.db

# Docker
.docker/
EOF

# Create README
log "📖 Creating README..."
cat > README.md << EOF
# $APP_NAME

A simple Node.js application created with Basic DevOps Toolkit.

## 🚀 Quick Start

### Using Docker (Recommended)
\`\`\`bash
# Build and start the app
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the app
docker-compose down
\`\`\`

### Local Development
\`\`\`bash
# Install dependencies
npm install

# Start the app
npm start
\`\`\`

## 📊 Endpoints

- **Main**: http://localhost:3000
- **Health**: http://localhost:3000/health
- **Info**: http://localhost:3000/api/info

## 🔧 Development

1. Copy \`.env.example\` to \`.env\`
2. Modify environment variables as needed
3. Start coding!

## 🚀 Deployment

This app is ready to deploy to any platform that supports Docker:
- Heroku
- DigitalOcean
- AWS
- Any VPS

## 📚 Learn More

- [Basic DevOps Toolkit](https://github.com/kasbahcode/basic-devops-toolkit)
- [Enterprise DevOps Toolkit](https://github.com/kasbahcode/devops-toolkit) (Advanced features)

## 📄 License

MIT License
EOF

# Install dependencies
log "📦 Installing dependencies..."
npm install

# Initial commit
log "📝 Creating initial commit..."
git add .
git commit -m "🎉 Initial commit: $APP_NAME created with Basic DevOps Toolkit

- ✅ Express.js application
- 🐳 Docker configuration
- 📊 Health check endpoint
- 📖 Complete documentation"

echo
log "✅ App '$APP_NAME' created successfully!"
echo
echo -e "${BLUE}🎉 Next steps:${NC}"
echo "1. cd $APP_NAME"
echo "2. docker-compose up -d"
echo "3. Visit http://localhost:3000"
echo
echo -e "${YELLOW}💡 Need databases, monitoring, or CI/CD?${NC}"
echo "   Upgrade to Enterprise DevOps Toolkit!"
echo "   https://github.com/kasbahcode/devops-toolkit" 