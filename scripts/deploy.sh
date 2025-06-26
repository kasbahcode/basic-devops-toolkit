#!/bin/bash

# 🚀 Simple Deploy Script
# Basic deployment to any server

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[INFO] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

# Default values
SERVER=""
APP_NAME=""
PORT="3000"

# Usage
usage() {
    cat << EOF
🚀 Simple Deploy Script

Usage: $0 [OPTIONS]

Options:
    -s, --server HOST      Server hostname or IP
    -a, --app NAME         App name to deploy
    -p, --port PORT        Port to run on [default: 3000]
    -h, --help             Show this help

Examples:
    $0 -s myserver.com -a my-app
    $0 --server 192.168.1.100 --app my-api --port 8080
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--server)
            SERVER="$2"
            shift 2
            ;;
        -a|--app)
            APP_NAME="$2"
            shift 2
            ;;
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

# Validate inputs
if [[ -z "$SERVER" ]]; then
    error "Server is required. Use -s or --server option."
fi

if [[ -z "$APP_NAME" ]]; then
    error "App name is required. Use -a or --app option."
fi

log "🚀 Starting deployment..."
log "Server: $SERVER"
log "App: $APP_NAME"
log "Port: $PORT"

# Check if we can connect to server
log "🔍 Testing server connection..."
if ! ssh -o ConnectTimeout=5 "$SERVER" "echo 'Connection successful'" >/dev/null 2>&1; then
    error "Cannot connect to server $SERVER. Check SSH access."
fi

# Check if Docker is installed on server
log "🐳 Checking Docker on server..."
if ! ssh "$SERVER" "command -v docker >/dev/null 2>&1"; then
    warn "Docker not found on server. Installing..."
    ssh "$SERVER" "curl -fsSL https://get.docker.com | sh && sudo usermod -aG docker \$USER"
    warn "Please log out and back in on the server for Docker permissions"
fi

# Create app directory on server
log "📁 Creating app directory on server..."
ssh "$SERVER" "mkdir -p ~/apps/$APP_NAME"

# Copy files to server
log "📤 Uploading files..."
if [[ ! -f "docker-compose.yml" ]]; then
    error "docker-compose.yml not found. Are you in the app directory?"
fi

# Create a simple deployment docker-compose
cat > docker-compose.deploy.yml << EOF
version: '3.8'

services:
  app:
    build: .
    container_name: ${APP_NAME}
    ports:
      - "${PORT}:3000"
    environment:
      - NODE_ENV=production
      - PORT=3000
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
EOF

# Upload files
rsync -avz --exclude node_modules --exclude .git . "$SERVER:~/apps/$APP_NAME/"
scp docker-compose.deploy.yml "$SERVER:~/apps/$APP_NAME/docker-compose.yml"

# Deploy on server
log "🚀 Deploying on server..."
ssh "$SERVER" "cd ~/apps/$APP_NAME && docker-compose down --remove-orphans || true"
ssh "$SERVER" "cd ~/apps/$APP_NAME && docker-compose build"
ssh "$SERVER" "cd ~/apps/$APP_NAME && docker-compose up -d"

# Wait for health check
log "⏳ Waiting for app to be ready..."
sleep 10

# Test deployment
log "🔍 Testing deployment..."
if ssh "$SERVER" "curl -sf http://localhost:$PORT/health >/dev/null"; then
    log "✅ Deployment successful!"
    echo
    echo -e "${BLUE}🎉 Your app is now running!${NC}"
    echo "URL: http://$SERVER:$PORT"
    echo "Health: http://$SERVER:$PORT/health"
    echo
    echo "Useful commands:"
    echo "  ssh $SERVER 'cd ~/apps/$APP_NAME && docker-compose logs -f'"
    echo "  ssh $SERVER 'cd ~/apps/$APP_NAME && docker-compose restart'"
    echo "  ssh $SERVER 'cd ~/apps/$APP_NAME && docker-compose down'"
else
    error "Deployment failed! Check logs with: ssh $SERVER 'cd ~/apps/$APP_NAME && docker-compose logs'"
fi

# Cleanup
rm -f docker-compose.deploy.yml

echo
echo -e "${YELLOW}💡 Need advanced deployment features?${NC}"
echo "   - Zero-downtime deployments"
echo "   - Auto-scaling"
echo "   - Load balancing"
echo "   - CI/CD pipelines"
echo
echo "   Upgrade to Enterprise DevOps Toolkit!"
echo "   https://github.com/kasbahcode/devops-toolkit" 