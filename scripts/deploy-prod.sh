#!/bin/bash
# Deploy script for Production
# This script is triggered by GitHub Actions workflow

set -e

echo "🚀 Deploying to Production..."

# Configuration
CONTAINER_NAME="cranky-container-prod"
IMAGE_NAME="${1:-cranky-container:latest}"
PORT=8000
APP_ENV="production"

echo "📋 Configuration:"
echo "  Image: $IMAGE_NAME"
echo "  Container: $CONTAINER_NAME"
echo "  Port: $PORT"
echo "  Environment: $APP_ENV"

# Safety check - require explicit approval
echo ""
echo "⚠️  PRODUCTION DEPLOYMENT"
echo "This will deploy to PRODUCTION environment"
echo ""

if [ "$CI" != "true" ]; then
  read -p "Continue? (yes/no): " confirm
  if [ "$confirm" != "yes" ]; then
    echo "Deployment cancelled"
    exit 1
  fi
fi

# Stop existing container (with backup)
echo "🛑 Stopping existing container..."
if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
  BACKUP_NAME="${CONTAINER_NAME}-backup-$(date +%s)"
  docker rename $CONTAINER_NAME $BACKUP_NAME || true
  echo "  Previous container backed up as: $BACKUP_NAME"
fi
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
sleep 10

# Verify deployment
echo "✅ Checking health endpoint..."
if curl -f http://localhost:$PORT/health > /dev/null 2>&1; then
  echo "✅ Production deployment successful!"
  echo "📍 Service is live"

  # Cleanup old backups (keep last 3)
  echo "🧹 Cleaning up old backups..."
  docker ps -a --format '{{.Names}}' | grep "^${CONTAINER_NAME}-backup-" | sort -V | head -n -3 | xargs -r docker rm -f || true

  exit 0
else
  echo "❌ Health check failed - Rolling back"
  docker logs $CONTAINER_NAME

  # Rollback to previous version
  BACKUP_NAME=$(docker ps -a --format '{{.Names}}' | grep "^${CONTAINER_NAME}-backup-" | sort -V | tail -1)
  if [ ! -z "$BACKUP_NAME" ]; then
    echo "🔄 Rolling back to: $BACKUP_NAME"
    docker rename $BACKUP_NAME $CONTAINER_NAME
    docker start $CONTAINER_NAME
    echo "✅ Rolled back to previous version"
  fi

  exit 1
fi
