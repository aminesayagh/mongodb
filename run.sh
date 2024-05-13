#!/bin/bash

echo "Run mongoDB containers"

# Disabling Transparent Huge Pages (THP)
echo "Disabling Transparent Huge Pages (THP)..."
sudo tee /sys/kernel/mm/transparent_hugepage/enabled <<< 'never'
sudo tee /sys/kernel/mm/transparent_hugepage/defrag <<< 'never'

# Setting vm.max_map_count for MongoDB
echo "Setting vm.max_map_count..."
sudo sysctl -w vm.max_map_count=262144

echo "Building Docker images..."
docker-compose build

# Start the services in detached mode
echo "Starting Docker containers in detached mode..."
docker-compose up -d

# Wait for MongoDB to be fully up
echo "Checking MongoDB readiness..."
echo "Checking MongoDB readiness..."
if docker-compose exec -T mongo1 mongosh -u toto -p toto --authenticationDatabase admin --eval "db.runCommand('ping')"; then
    echo "MongoDB is up and responding to ping."
else
    echo "MongoDB is unavailable - check logs for details."
    docker-compose logs mongo1
    exit 1
fi

# >&2 echo "MongoDB is up - executing command"
docker-compose exec -T mongo1 mongosh -u toto -p toto 

echo "MongoDB is running on port 27017."
echo "List of running containers..."
docker-compose ps

echo "Docker containers are up and running."