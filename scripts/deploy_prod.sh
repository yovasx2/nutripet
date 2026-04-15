#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/deploy_prod.sh root@your.vps.ip
REMOTE_HOST=${1:-root@187.77.19.49}
REPO_URL=git@github.com:yovasx2/nutripet.git
APP_DIR=/opt/nutripet
COMPOSE_FILE=docker-compose.prod.yml
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Deploying to $REMOTE_HOST"

ssh $REMOTE_HOST "mkdir -p $APP_DIR && cd $APP_DIR && if [ ! -d .git ]; then git clone $REPO_URL .; else git fetch origin && git reset --hard origin/main; fi"

# Copy env file if present locally
if [ -f "$PROJECT_DIR/.env.production" ]; then
  echo "Uploading .env.production"
  scp "$PROJECT_DIR/.env.production" $REMOTE_HOST:$APP_DIR/.env.production
else
  echo "No local .env.production found at $PROJECT_DIR/.env.production. Make sure to create one before deploy."
fi

# Ensure infrastructure services are running
ssh $REMOTE_HOST "cd $APP_DIR && docker compose --env-file .env.production -f $COMPOSE_FILE up -d db"

# Build new image
ssh $REMOTE_HOST "cd $APP_DIR && docker compose --env-file .env.production -f $COMPOSE_FILE build nutripet"

# Run migrations
ssh $REMOTE_HOST "cd $APP_DIR && docker compose --env-file .env.production -f $COMPOSE_FILE run --rm nutripet rails db:migrate RAILS_ENV=production"

# Precompile assets
ssh $REMOTE_HOST "cd $APP_DIR && docker compose --env-file .env.production -f $COMPOSE_FILE run --rm nutripet rails assets:precompile RAILS_ENV=production"

# Deploy with zero-downtime: wait for health check before stopping old container
ssh $REMOTE_HOST "cd $APP_DIR && docker compose --env-file .env.production -f $COMPOSE_FILE up -d --wait --no-deps nutripet"

echo "Deployment to $REMOTE_HOST finished."
