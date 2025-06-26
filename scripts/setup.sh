#!/bin/bash

# 🚀 Basic DevOps Toolkit Setup
# Simple setup for beginners

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[INFO] $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

log "🔍 Detected OS: $MACHINE"

# Install Docker
install_docker() {
    log "🐳 Checking Docker..."
    
    if command_exists docker; then
        log "✅ Docker already installed"
        return
    fi
    
    log "📦 Installing Docker..."
    
    if [[ "$MACHINE" == "Mac" ]]; then
        if command_exists brew; then
            brew install --cask docker
        else
            warn "Please install Docker Desktop from https://docker.com"
        fi
    elif [[ "$MACHINE" == "Linux" ]]; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
        warn "Please log out and back in for Docker permissions"
    fi
}

# Install Node.js
install_nodejs() {
    log "🟢 Checking Node.js..."
    
    if command_exists node; then
        log "✅ Node.js already installed"
        return
    fi
    
    log "📦 Installing Node.js..."
    
    if [[ "$MACHINE" == "Mac" ]]; then
        if command_exists brew; then
            brew install node
        else
            warn "Please install Node.js from https://nodejs.org"
        fi
    elif [[ "$MACHINE" == "Linux" ]]; then
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
}

# Make scripts executable
make_executable() {
    log "🔧 Making scripts executable..."
    chmod +x scripts/*.sh 2>/dev/null || true
}

# Create example environment file
create_env_example() {
    log "📄 Creating .env.example..."
    
    cat > .env.example << 'EOF'
# Basic DevOps Toolkit Environment

# Application
NODE_ENV=development
PORT=3000

# Database (if needed)
DATABASE_URL=sqlite://./database.db

# Basic monitoring
HEALTH_CHECK_INTERVAL=30
EOF

    log "✅ Created .env.example"
}

# Main setup function
main() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                  🚀 Basic DevOps Toolkit                    ║"
    echo "║                     Simple & Free                           ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    log "🚀 Starting basic setup..."
    
    install_docker
    install_nodejs
    create_env_example
    make_executable
    
    echo
    log "✅ Setup completed successfully!"
    echo
    echo -e "${BLUE}🎉 You're ready to create your first app!${NC}"
    echo
    echo "Next steps:"
    echo "1. ./scripts/create-app.sh my-first-app"
    echo "2. cd my-first-app"
    echo "3. docker-compose up -d"
    echo
    echo -e "${YELLOW}💡 Need more features? Check out the Enterprise DevOps Toolkit!${NC}"
    echo "   https://github.com/kasbahcode/devops-toolkit"
}

# Run main function
main "$@" 