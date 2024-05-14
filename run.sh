#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "Run mongoDB containers"

# Disabling Transparent Huge Pages (THP)
echo "Disabling Transparent Huge Pages (THP)..."
if sudo tee /sys/kernel/mm/transparent_hugepage/enabled <<< 'never' && sudo tee /sys/kernel/mm/transparent_hugepage/defrag <<< 'never'; then
    echo 'THP disabled.'
else
    echo 'Failed to disable THP.' >&2
    exit 1
fi

# Setting vm.max_map_count for MongoDB
echo "Setting vm.max_map_count..."
if sudo sysctl -w vm.max_map_count=262144; then
    echo "vm.max_map_count set."
else
    echo "Failed to set vm.max_map_count." >&2
    exit 1
fi

echo "Setting key file permissions..."
if chmod 400 ./mongodb-keyfile; then
    echo "Key file permissions set."
else
    echo "Failed to set key file permissions." >&2
    exit 1
fi


echo "Building Docker images..."
if docker-compose build; then
    echo "Docker images built."
else
    echo "Failed to build Docker images." >&2
    exit 1
fi

# Start the services in detached mode
echo "Starting Docker containers in detached mode..."
if docker-compose up -d; then
    echo "Docker containers started."
else
    echo "Failed to start Docker containers." >&2
    exit 1
fi

# Check the status of the containers
# Check the status of the key file in the container
echo "Checking key file in the container..."
if docker-compose exec mongo1 ls -l /data/keyfile; then
    echo "Key file is correctly mounted."
else
    echo "Failed to mount key file." >&2
    exit 1
fi


# Wait for MongoDB to be fully up
echo "Checking MongoDB readiness..."
if docker-compose exec -T mongo1 mongosh -u toto -p toto --authenticationDatabase admin --eval "db.runCommand('ping')"; then
    echo "MongoDB is up and responding to ping."
else
    echo "MongoDB is unavailable - check logs for details."
    docker-compose logs mongo1
    exit 1
fi


echo "MongoDB is running on port 27017."
echo "List of running containers..."
docker-compose ps

echo "Docker containers are up and running."
