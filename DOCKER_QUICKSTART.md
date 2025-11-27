# Quick Start with Docker

## Using the Management Script (Easiest)

1. **Setup environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your credentials
   ```

2. **Start the bot:**
   ```bash
   ./docker-manage.sh start
   ```

3. **View logs:**
   ```bash
   ./docker-manage.sh logs
   ```

4. **Stop the bot:**
   ```bash
   ./docker-manage.sh stop
   ```

## Manual Docker Commands

### Build the image:
```bash
docker compose build
```

### Start the bot:
```bash
docker compose up -d
```

### View logs:
```bash
docker compose logs -f tedicross
```

### Stop the bot:
```bash
docker compose down
```

## Available Management Commands

- `./docker-manage.sh build` - Build the Docker image
- `./docker-manage.sh start` - Start the bot and database
- `./docker-manage.sh stop` - Stop all containers
- `./docker-manage.sh restart` - Restart the bot
- `./docker-manage.sh logs` - View real-time logs
- `./docker-manage.sh status` - Check container status
- `./docker-manage.sh update` - Update and rebuild the bot
- `./docker-manage.sh backup` - Backup MongoDB data
- `./docker-manage.sh shell` - Access container shell

For detailed documentation, see [DOCKER_GUIDE.md](DOCKER_GUIDE.md)
