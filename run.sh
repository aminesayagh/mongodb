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

echo "Checking the key file inside the container..."
docker-compose exec -T mongo1 ls -l /etc/mongo-keyfile
docker-compose exec -T mongo1 cat /etc/mongo-keyfile

# Wait for MongoDB to be fully up
echo "Checking MongoDB readiness..."
counter=0
until docker-compose exec -T mongo1 mongosh -u toto -p toto --authenticationDatabase admin --eval "db.adminCommand('ping')"; do
    >&2 echo "MongoDB is unavailable - sleeping"
    sleep 2
    counter=$((counter+1))
    if [ $counter -eq 10 ]; then
        >&2 echo "MongoDB took too long to start"
        docker-compose logs
        exit 1
    fi
done

>&2 echo "MongoDB is up - executing command"
docker-compose exec -T mongo1 mongosh -u toto -p toto --authenticationDatabase admin

echo "MongoDB is running on port 27017."
echo "List of running containers..."
docker-compose ps

echo "Docker containers are up and running."