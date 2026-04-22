#!/bin/bash
# Deploy script for Staging (GCP VM)
# This script is triggered by GitHub Actions workflow

set -e

echo "🚀 Deploying to Staging (GCP)..."

# Configuration
CONTAINER_NAME="cranky-container-staging"
IMAGE_NAME="${1:-cranky-container:latest}"
PORT=8001
APP_ENV="staging"

echo "📋 Configuration:"
echo "  Image: $IMAGE_NAME"
echo "  Container: $CONTAINER_NAME"
echo "  Port: $PORT"
echo "  Environment: $APP_ENV"

# Stop existing container
echo "🛑 Stopping existing container..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

# Pull latest image
echo "📥 Pulling latest image..."
docker pull $IMAGE_NAME || {
  echo "❌ Failed to pull image"
  exit 1
}

# Run new container
echo "▶️  Starting new container..."
docker run -d \
  --name $CONTAINER_NAME \
  --restart always \
  -p $PORT:8000 \
  -e ENVIRONMENT=$APP_ENV \
  -e DEPLOYMENT_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
  -e DEPLOYMENT_BY="${GITHUB_ACTOR:-ci-bot}" \
  --health-cmd="curl -f http://localhost:8000/health || exit 1" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  $IMAGE_NAME

echo "⏳ Waiting for health check..."
sleep 5

# Verify deployment
echo "✅ Checking health endpoint..."
if curl -f http://localhost:$PORT/health > /dev/null 2>&1; then
  echo "✅ Staging deployment successful!"
  echo "📍 URL: http://34.21.136.25:$PORT"
  exit 0
else
  echo "❌ Health check failed"
  docker logs $CONTAINER_NAME
  exit 1
fi
