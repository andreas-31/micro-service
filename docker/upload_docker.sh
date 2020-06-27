#!/usr/bin/env bash
# This file tags and uploads an image to Docker Hub

# Assumes that an image is built via `run_docker.sh`

# Step 1:
# Create dockerpath
username=itsecat
appname=flask-app
dockerpath="$username/$appname"

# Step 2: Build the docker image
docker build --tag "$appname" .

# Step 3:  
# Authenticate & tag
echo "Docker ID and Image: $dockerpath"
docker login --username "$username"
docker tag "$appname" "$dockerpath"

# Step 4:
# Push image to a docker repository
docker push "$dockerpath"
