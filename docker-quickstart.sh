#!/bin/bash
# Quick start script for Docker deployment

set -e

echo "=========================================="
echo "Polymarket Copy Bot - Docker Quick Start"
echo "=========================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed."
    echo "Please install Docker from: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null; then
    echo "❌ Error: Docker Compose is not available."
    echo "Please install Docker Compose or update Docker to a version that includes it."
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "📋 Creating .env file from .env.example..."
    cp .env.example .env
    echo "✅ .env file created"
    echo ""
    echo "⚠️  IMPORTANT: Please edit the .env file with your configuration:"
    echo "   - USER_ADDRESSES: Traders to copy"
    echo "   - PROXY_WALLET: Your wallet address"
    echo "   - PRIVATE_KEY: Your wallet private key"
    echo "   - MONGO_URI: MongoDB connection string"
    echo "   - RPC_URL: Polygon RPC endpoint"
    echo ""
    echo "After editing .env, run this script again or use:"
    echo "   docker compose up -d"
    exit 0
fi

echo "✅ .env file found"
echo ""

# Ask user if they want to use local MongoDB
read -p "Do you want to use a local MongoDB instance? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🐳 Using docker-compose.example.yml with local MongoDB..."
    COMPOSE_FILE="docker-compose.example.yml"
    
    # Generate a random password if not provided
    read -sp "Enter MongoDB password (or press Enter to generate a secure random password): " MONGO_PASSWORD
    echo ""
    
    if [ -z "$MONGO_PASSWORD" ]; then
        # Generate a secure random password (alphanumeric only to avoid shell escaping issues)
        MONGO_PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32)
        echo "✅ Generated secure MongoDB password: $MONGO_PASSWORD"
        echo "⚠️  IMPORTANT: Save this password securely! You'll need it to access MongoDB."
        echo "              Password is only shown once and stored in environment variable."
        echo ""
    fi
    
    echo "⚠️  SECURITY NOTES:"
    echo "    - This MongoDB instance is for LOCAL TESTING only"
    echo "    - For production, use a managed service like MongoDB Atlas"
    echo "    - Password is stored in environment variable for this session only"
    echo "    - Consider using Docker secrets for production deployments"
    echo ""
    
    export MONGO_PASSWORD
else
    echo "🐳 Using docker-compose.yml with external MongoDB..."
    COMPOSE_FILE="docker-compose.yml"
fi

echo ""
echo "🏗️  Building Docker image..."
docker compose -f "$COMPOSE_FILE" build

echo ""
echo "🚀 Starting containers..."
docker compose -f "$COMPOSE_FILE" up -d

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 View logs:"
echo "   docker compose -f $COMPOSE_FILE logs -f"
echo ""
echo "🔍 Check status:"
echo "   docker compose -f $COMPOSE_FILE ps"
echo ""
echo "🛑 Stop the bot:"
echo "   docker compose -f $COMPOSE_FILE down"
echo ""
echo "📖 For more information, see docs/DOCKER.md"
