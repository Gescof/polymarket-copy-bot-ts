# Docker Deployment Guide

This guide explains how to run the Polymarket Copy Trading Bot using Docker and Docker Compose.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (version 20.10 or later with Compose V2)
- A configured `.env` file (copy from `.env.example` and fill in your settings)

> **Note:** Modern Docker installations (Docker Desktop, Docker Engine 20.10+) include Docker Compose V2 by default. This guide uses the `docker compose` command (V2 syntax).

## Quick Start

### Using the Quick Start Script (Easiest)

For the fastest setup, use the provided script:

```bash
# Run the quick start script
./docker-quickstart.sh
```

The script will:
1. Check if Docker is installed
2. Create `.env` file if it doesn't exist
3. Ask if you want to use local MongoDB
4. Build and start the containers
5. Show you how to view logs and manage the bot

### Manual Setup

### 1. Configure Environment Variables

Copy the example environment file and configure your settings:

```bash
cp .env.example .env
```

Edit `.env` with your configuration:
- Add trader addresses to `USER_ADDRESSES`
- Set your `PROXY_WALLET` and `PRIVATE_KEY`
- Configure `MONGO_URI` for your MongoDB database
- Set `RPC_URL` for Polygon network access

### 2. Build and Run with Docker Compose

#### Production Mode

Build and start the bot in production mode:

```bash
# Build the Docker image
docker compose build

# Start the bot in detached mode
docker compose up -d

# View logs
docker compose logs -f

# Stop the bot
docker compose down
```

#### Production Mode with Local MongoDB

If you want to run MongoDB locally alongside the bot:

```bash
# Use the example compose file that includes MongoDB
docker compose -f docker-compose.example.yml up -d

# View logs
docker compose -f docker-compose.example.yml logs -f

# Stop everything
docker compose -f docker-compose.example.yml down
```

#### Development Mode

For development with hot reloading:

```bash
# Build and start in development mode
docker compose -f docker-compose.dev.yml up --build

# Stop the development container
docker compose -f docker-compose.dev.yml down
```

### 3. Monitor the Bot

View real-time logs:
```bash
docker compose logs -f polymarket-bot
```

Check bot status:
```bash
docker compose ps
```

Check health status:
```bash
docker compose exec polymarket-bot node dist/scripts/healthCheck.js
```

## Available Docker Files

The repository includes several Docker-related files:

- **`Dockerfile`** - Production-optimized multi-stage build
- **`Dockerfile.dev`** - Development image with all dev dependencies
- **`docker-compose.yml`** - Standard deployment (you provide MongoDB)
- **`docker-compose.dev.yml`** - Development setup with hot reloading
- **`docker-compose.example.yml`** - Full stack with local MongoDB
- **`docker-quickstart.sh`** - Interactive setup script
- **`.dockerignore`** - Files excluded from Docker build

## Docker Commands Reference

### Building

```bash
# Build the Docker image
docker compose build

# Build without cache (clean build)
docker compose build --no-cache

# Build a specific service
docker compose build polymarket-bot
```

### Running

```bash
# Start containers in detached mode
docker compose up -d

# Start containers in foreground
docker compose up

# Start and rebuild if needed
docker compose up -d --build

# Restart the bot
docker compose restart
```

### Logs and Monitoring

```bash
# View all logs
docker compose logs

# Follow logs (real-time)
docker compose logs -f

# View last 100 lines
docker compose logs --tail=100

# View logs for specific service
docker compose logs polymarket-bot
```

### Stopping and Cleaning

```bash
# Stop containers
docker compose stop

# Stop and remove containers
docker compose down

# Stop, remove containers, and remove volumes
docker compose down -v

# Remove unused images
docker image prune -a
```

### Executing Commands

```bash
# Run health check
docker compose exec polymarket-bot npm run health-check

# Access container shell
docker compose exec polymarket-bot sh

# Run a script inside container
docker compose exec polymarket-bot npm run check-stats
```

## Configuration

### Resource Limits

The `docker-compose.yml` file includes resource limits. Adjust these based on your system:

```yaml
deploy:
  resources:
    limits:
      cpus: '1.0'      # Maximum CPU cores
      memory: 512M     # Maximum memory
    reservations:
      cpus: '0.5'      # Minimum CPU cores
      memory: 256M     # Minimum memory
```

### Persistent Data

To persist logs and data, uncomment the volume mounts in `docker-compose.yml`:

```yaml
volumes:
  - ./logs:/app/logs
  - ./simulation_results:/app/simulation_results
  - ./trader_data_cache:/app/trader_data_cache
```

### Health Checks

The container includes a health check that runs every 60 seconds. Check health status:

```bash
docker inspect --format='{{.State.Health.Status}}' polymarket-copy-bot
```

## Troubleshooting

### Container Won't Start

1. Check logs:
   ```bash
   docker compose logs polymarket-bot
   ```

2. Verify `.env` file is configured correctly

3. Check if required ports are available

4. Ensure sufficient disk space

### Network Issues

If you experience connectivity issues, try using host network mode in `docker-compose.yml`:

```yaml
network_mode: host
```

### Memory Issues

If the bot runs out of memory, increase the memory limit:

```yaml
deploy:
  resources:
    limits:
      memory: 1G  # Increase to 1GB
```

### Database Connection Issues

1. Verify `MONGO_URI` is correct in `.env`
2. Ensure MongoDB is accessible from the Docker container
3. Check network connectivity

### Viewing Environment Variables

```bash
docker compose exec polymarket-bot env
```

### Rebuilding After Changes

After making changes to the code or Dockerfile:

```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

## Production Deployment

### Using Docker Image

Build and tag the image for production:

```bash
# Build image
docker build -t polymarket-copy-bot:latest .

# Run container
docker run -d \
  --name polymarket-bot \
  --env-file .env \
  --restart unless-stopped \
  polymarket-copy-bot:latest
```

### Security Best Practices

1. **Never commit `.env` file** - It contains sensitive credentials
2. **Use Docker secrets** for sensitive data in production
3. **Run as non-root user** (already configured in Dockerfile)
4. **Keep base images updated** - Rebuild regularly with latest Node.js
5. **Limit resources** - Use appropriate CPU and memory limits
6. **Enable logging** - Monitor container logs for issues

### Automated Restarts

The bot is configured with `restart: unless-stopped`, which means:
- Automatically restarts on failure
- Restarts when Docker daemon starts
- Won't restart if manually stopped

### Updating the Bot

```bash
# Pull latest code
git pull

# Rebuild and restart
docker compose down
docker compose build --no-cache
docker compose up -d
```

## Advanced Configuration

### Multi-Container Setup with Local MongoDB

The repository includes `docker-compose.example.yml` which provides a complete setup with MongoDB:

```bash
# Recommended: Use the quick-start script (auto-generates secure password)
./docker-quickstart.sh

# Or set password via environment variable
# WARNING: Command-line passwords may be visible in shell history
export MONGO_PASSWORD='your_secure_password'
docker compose -f docker-compose.example.yml up -d

# Alternative: Use .env file for better security (recommended)
# Create or overwrite .env.local file
echo "MONGO_PASSWORD=your_secure_password" > .env.local
docker compose -f docker-compose.example.yml --env-file .env.local up -d

# Don't forget to add .env.local to .gitignore
echo ".env.local" >> .gitignore
```

**Security Note:** Passing passwords on the command line exposes them in shell history and process listings. For better security:
1. Use `docker-quickstart.sh` which handles passwords securely
2. Store passwords in a `.env` file (add to .gitignore)
3. Use Docker secrets in production environments
4. Use managed MongoDB services (MongoDB Atlas) for production

The example file includes:
- MongoDB 7.0.15 (pinned version) with authentication
- Persistent data volumes
- Health checks and proper service dependencies
- Automatic connection configuration
- Required password (no insecure defaults)

For production use, consider using a managed MongoDB service like MongoDB Atlas instead of running MongoDB in a container.

### Custom Build Arguments

You can pass build arguments during build:

```bash
docker build \
  --build-arg NODE_VERSION=18 \
  -t polymarket-copy-bot:latest .
```

## Support

For issues or questions:
- Check the [main README](../README.md)
- Review logs: `docker compose logs -f`
- Contact via Discord: `jonathansharpes`

## License

MIT License - See [LICENSE](../LICENSE.md) file for details.
