# TediCross Docker Containerization Guide

This guide provides step-by-step instructions to containerize and run your TediCross Discord-Telegram bridge bot using Docker.

## Prerequisites

- Docker installed on your system ([Install Docker](https://docs.docker.com/get-docker/))
- Docker Compose installed (included with Docker Desktop)
- Basic knowledge of terminal/command line
- Your bot tokens and API credentials

---

## Step 1: Prepare Environment Variables

Create a `.env` file in the project root directory with your bot credentials:

```bash
cp .env.example .env
```

Edit the `.env` file and fill in your actual credentials:

```env
DISCORDTOKEN=your_discord_bot_token_here
TGTOKEN=your_telegram_bot_token_here
API_ID=your_telegram_api_id
API_HASH=your_telegram_api_hash
MONGO_URI=mongodb://mongodb:27017/tedicross
```

**Important:** 
- Never commit the `.env` file to version control (it's already in `.gitignore`)
- The `MONGO_URI` uses `mongodb` as the hostname (the Docker Compose service name)

---

## Step 2: Configure Your Bridge Settings

Edit `config.json` to set up your Discord-Telegram bridges:

```json
{
    "bridges": [
        {
            "name": "Your Bridge Name",
            "discord": {
                "chat_id": "discord_channel_id"
            },
            "telegram": {
                "chat_id": "telegram_chat_id"
            },
            "hide": false,
            "disabled": false
        }
    ],
    "ignore_bots": true,
    "owner": {
        "discord": "your_discord_user_id",
        "telegram": "your_telegram_user_id"
    },
    "check_for_deleted_messages": false,
    "deleted_message_check_interval": 5
}
```

---

## Step 3: Build the Docker Image

Build the Docker image using the Dockerfile:

```bash
docker build -t tedicross:latest .
```

**What this does:**
- `-t tedicross:latest` - Tags the image with name "tedicross" and version "latest"
- `.` - Uses the current directory as build context

**Expected output:** You'll see Docker executing each step in the Dockerfile, installing dependencies, and compiling TypeScript.

---

## Step 4: Run with Docker Compose (Recommended)

The easiest way to run TediCross with all dependencies:

```bash
docker compose up -d
```

**What this does:**
- Starts both the TediCross bot and MongoDB database
- `-d` flag runs containers in detached mode (background)
- Automatically creates a network for services to communicate
- Sets up persistent storage for MongoDB data

**Verify it's running:**
```bash
docker compose ps
```

**View logs:**
```bash
docker compose logs -f tedicross
```

**Stop the bot:**
```bash
docker compose down
```

---

## Step 5: Alternative - Run with Docker Only

If you have an external MongoDB instance or prefer manual container management:

```bash
docker run -d \
  --name tedicross-bot \
  --env-file .env \
  -v $(pwd)/config.json:/app/config.json:ro \
  --restart unless-stopped \
  tedicross:latest
```

**What this does:**
- `-d` - Runs container in detached mode
- `--name tedicross-bot` - Names the container
- `--env-file .env` - Loads environment variables from `.env` file
- `-v $(pwd)/config.json:/app/config.json:ro` - Mounts config file as read-only
- `--restart unless-stopped` - Automatically restarts if it crashes

**View logs:**
```bash
docker logs -f tedicross-bot
```

**Stop the container:**
```bash
docker stop tedicross-bot
```

**Remove the container:**
```bash
docker rm tedicross-bot
```

---

## Best Practices & Configuration Details

### Docker Multi-Stage Build
The Dockerfile uses a multi-stage build to:
- **Builder stage:** Compiles TypeScript with all dev dependencies
- **Production stage:** Runs only compiled JavaScript with production dependencies
- **Result:** Smaller final image size and improved security

### Security Features
1. **Non-root user:** The container runs as user `nodejs` (UID 1001) instead of root
2. **Read-only config:** The `config.json` is mounted read-only to prevent accidental modifications
3. **No secrets in image:** Environment variables are passed at runtime, not baked into the image

### Resource Management
```yaml
# Add to docker-compose.yml under the tedicross service:
deploy:
  resources:
    limits:
      cpus: '1.0'
      memory: 512M
    reservations:
      cpus: '0.5'
      memory: 256M
```

### Logging Configuration
The Docker Compose file includes log rotation to prevent disk space issues:
- Maximum log file size: 10MB
- Maximum number of log files: 3

---

## Maintenance & Troubleshooting

### Updating the Bot

1. Pull latest code changes:
```bash
git pull
```

2. Rebuild and restart:
```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Viewing Logs

**Real-time logs:**
```bash
docker compose logs -f tedicross
```

**Last 100 lines:**
```bash
docker compose logs --tail=100 tedicross
```

**MongoDB logs:**
```bash
docker compose logs -f mongodb
```

### Common Issues

**Issue: Bot can't connect to MongoDB**
- Ensure `MONGO_URI=mongodb://mongodb:27017/tedicross` in `.env`
- Verify both services are in the same network: `docker network inspect tedicross_tedicross-network`

**Issue: Bot disconnects frequently**
- Check logs: `docker compose logs tedicross`
- Verify tokens are correct in `.env`
- Ensure adequate resources are allocated

**Issue: Changes to config.json not reflected**
- Restart the container: `docker compose restart tedicross`
- The config is mounted as a volume, so no rebuild needed

### Accessing the Container

To debug or inspect the running container:
```bash
docker compose exec tedicross sh
```

### Backing Up MongoDB Data

```bash
docker compose exec mongodb mongodump --out=/dump
docker cp tedicross-mongodb:/dump ./mongodb-backup
```

### Restoring MongoDB Data

```bash
docker cp ./mongodb-backup tedicross-mongodb:/dump
docker compose exec mongodb mongorestore /dump
```

---

## Production Deployment Tips

1. **Use specific image versions** instead of `latest` for reproducible deployments
2. **Set up monitoring** with tools like Prometheus or Datadog
3. **Configure health checks** to automatically restart unhealthy containers
4. **Use Docker secrets** for sensitive data in production environments
5. **Enable automatic updates** with Watchtower or similar tools
6. **Set up backup automation** for MongoDB data
7. **Use a reverse proxy** (nginx/Traefik) if exposing any web endpoints

### Example Health Check

Add to `docker-compose.yml` under the tedicross service:
```yaml
healthcheck:
  test: ["CMD", "node", "-e", "require('http').get('http://localhost:8080/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

---

## Summary

Your TediCross bot is now fully containerized with:
- ✅ Optimized multi-stage Docker build
- ✅ Automatic restarts on failure
- ✅ Isolated network environment
- ✅ Persistent MongoDB storage
- ✅ Security best practices (non-root user, read-only mounts)
- ✅ Easy configuration management
- ✅ Production-ready setup

The bot maintains full functionality including:
- Discord message bridging
- Telegram message bridging
- Media handling
- Command processing
- Database persistence

For questions or issues, refer to the project README or check the logs using the commands above.
