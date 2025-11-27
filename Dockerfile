# Use official Node.js LTS (Long Term Support) image as base
# Using Debian-based image instead of Alpine due to Deno compatibility requirements
FROM node:20-slim AS builder

# Set working directory
WORKDIR /app

# Install git (required for GitHub dependencies), unzip (for Deno), and pnpm
RUN apt-get update && \
    apt-get install -y git unzip curl ca-certificates && \
    npm install -g pnpm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy package files for dependency installation
COPY package.json pnpm-lock.yaml ./

# Install dependencies (update lockfile if needed for compatibility)
RUN pnpm install --no-frozen-lockfile

# Copy TypeScript configuration and source code
COPY tsconfig.json ./
COPY src ./src

# Build TypeScript to JavaScript
RUN pnpm run build

# Production stage - creates a smaller final image
FROM node:20-slim

# Set working directory
WORKDIR /app

# Install git (required for GitHub dependencies), unzip (for Deno), and pnpm
RUN apt-get update && \
    apt-get install -y git unzip curl ca-certificates && \
    npm install -g pnpm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install only production dependencies
RUN pnpm install --prod --no-frozen-lockfile

# Copy built application from builder stage
COPY --from=builder /app/dist ./dist

# Copy configuration file
COPY config.json ./

# Create a non-root user for security
RUN groupadd --gid 1001 nodejs && \
    useradd --uid 1001 --gid nodejs --shell /bin/bash --create-home nodejs && \
    chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Set environment to production
ENV NODE_ENV=production

# Start the bot
CMD ["node", "dist/index.js"]
