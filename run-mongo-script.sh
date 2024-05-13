#!/bin/bash

echo "Executing MongoDB script..."

# Use mongosh to run the script on MongoDB container
docker-compose exec -T mongo1 mongosh < mongo-script.js

echo "Script execution complete."
