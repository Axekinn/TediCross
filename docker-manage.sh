#!/bin/bash

# TediCross Docker Management Script
# This script provides convenient commands for managing your containerized bot

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

function print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

function print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

function print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

function print_error() {
    echo -e "${RED}✗ $1${NC}"
}

function check_env_file() {
    if [ ! -f ".env" ]; then
        print_error ".env file not found!"
        echo "Please create a .env file from .env.example:"
        echo "  cp .env.example .env"
        echo "Then edit it with your bot credentials."
        exit 1
    fi
}

function build() {
    print_header "Building Docker Image"
    docker compose build --no-cache
    print_success "Image built successfully"
}

function start() {
    print_header "Starting TediCross Bot"
    check_env_file
    docker compose up -d
    print_success "Bot started successfully"
    echo ""
    echo "View logs with: ./docker-manage.sh logs"
}

function stop() {
    print_header "Stopping TediCross Bot"
    docker compose down
    print_success "Bot stopped successfully"
}

function restart() {
    print_header "Restarting TediCross Bot"
    docker compose restart tedicross
    print_success "Bot restarted successfully"
}

function logs() {
    print_header "Viewing Bot Logs (Ctrl+C to exit)"
    docker compose logs -f tedicross
}

function logs_all() {
    print_header "Viewing All Logs (Ctrl+C to exit)"
    docker compose logs -f
}

function status() {
    print_header "Container Status"
    docker compose ps
}

function shell() {
    print_header "Opening Shell in Container"
    docker compose exec tedicross sh
}

function update() {
    print_header "Updating TediCross Bot"
    print_warning "This will rebuild the image and restart the bot"
    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker compose down
        docker compose build --no-cache
        docker compose up -d
        print_success "Bot updated and restarted"
    else
        print_warning "Update cancelled"
    fi
}

function clean() {
    print_header "Cleaning Up Docker Resources"
    print_warning "This will remove stopped containers and unused images"
    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker compose down
        docker system prune -f
        print_success "Cleanup completed"
    else
        print_warning "Cleanup cancelled"
    fi
}

function backup() {
    print_header "Backing Up MongoDB Data"
    BACKUP_DIR="./backups/mongodb_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    docker compose exec -T mongodb mongodump --archive > "$BACKUP_DIR/dump.archive"
    print_success "Backup saved to: $BACKUP_DIR/dump.archive"
}

function restore() {
    print_header "Restoring MongoDB Data"
    if [ -z "$1" ]; then
        print_error "Please specify backup file path"
        echo "Usage: ./docker-manage.sh restore <backup-file>"
        exit 1
    fi
    if [ ! -f "$1" ]; then
        print_error "Backup file not found: $1"
        exit 1
    fi
    print_warning "This will restore database from: $1"
    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker compose exec -T mongodb mongorestore --archive < "$1"
        print_success "Database restored successfully"
    else
        print_warning "Restore cancelled"
    fi
}

function show_help() {
    echo "TediCross Docker Management Script"
    echo ""
    echo "Usage: ./docker-manage.sh [command]"
    echo ""
    echo "Available commands:"
    echo "  build       - Build the Docker image"
    echo "  start       - Start the bot and database"
    echo "  stop        - Stop all containers"
    echo "  restart     - Restart the bot container"
    echo "  logs        - View bot logs (live)"
    echo "  logs-all    - View all container logs (live)"
    echo "  status      - Show container status"
    echo "  shell       - Open shell in bot container"
    echo "  update      - Rebuild and restart the bot"
    echo "  clean       - Clean up Docker resources"
    echo "  backup      - Backup MongoDB database"
    echo "  restore     - Restore MongoDB database from backup"
    echo "  help        - Show this help message"
    echo ""
}

# Main command handler
case "${1:-}" in
    build)
        build
        ;;
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    logs)
        logs
        ;;
    logs-all)
        logs_all
        ;;
    status)
        status
        ;;
    shell)
        shell
        ;;
    update)
        update
        ;;
    clean)
        clean
        ;;
    backup)
        backup
        ;;
    restore)
        restore "$2"
        ;;
    help|--help|-h)
        show_help
        ;;
    "")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
