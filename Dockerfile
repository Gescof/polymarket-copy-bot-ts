# Polymarket Copy Trading Bot - Dockerfile
# Multi-stage build for optimized image size

# Stage 1: Build stage
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including devDependencies for building)
RUN npm ci

# Copy source code
COPY . .

# Build TypeScript code
RUN npm run build

# Stage 2: Production stage
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production

# Copy built files from builder stage
COPY --from=builder /app/dist ./dist

# Copy necessary files
COPY --from=builder /app/src/scripts/postinstall.js ./src/scripts/postinstall.js

# Create directory for logs (optional)
RUN mkdir -p logs

# Set environment to production
ENV NODE_ENV=production

# Run postinstall script
RUN npm run postinstall || true

# Expose no ports (this is a bot, not a server)

# Health check (runs the health-check script)
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
  CMD node dist/scripts/healthCheck.js || exit 1

# Run the application
CMD ["npm", "start"]
