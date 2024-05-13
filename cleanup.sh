#!/bin/bash

echo "Stopping Docker containers..."

# Stop and remove containers, networks created by up.
docker-compose down

# Remove all stopped containers
echo "Removing all stopped containers..."
docker container prune -f

# Remove all networks not used by at least one container
echo "Removing all unused networks..."
docker network prune -f

# Remove all dangling images
echo "Removing all unused Docker images..."
docker image prune -a -f

# Remove all unused volumes
echo "Removing all unused Docker volumes..."
docker volume prune -f

echo "Docker cleanup complete."