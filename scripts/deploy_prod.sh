#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/deploy_prod.sh root@your.vps.ip
REMOTE_HOST=${1:-root@187.77.19.49}
REPO_URL=git@github.com:yovasx2/nutripet.git
APP_DIR=/opt/nutripet
COMPOSE_FILE=docker-compose.prod.yml

echo "Deploying to $REMOTE_HOST"

ssh $REMOTE_HOST "mkdir -p $APP_DIR && cd $APP_DIR && if [ ! -d .git ]; then git clone $REPO_URL .; else git fetch origin && git reset --hard origin/main; fi"

# Copy env file if present locally
if [ -f .env.production ]; then
  echo "Uploading .env.production"
  scp .env.production $REMOTE_HOST:$APP_DIR/.env.production
else
  echo "No local .env.production found. Make sure to create one on the VPS at $APP_DIR/.env.production"
fi

# Load environment variables from .env.production
if [ -f .env.production ]; then
  set -a
  source .env.production
  set +a
fi

# Ensure infrastructure services are running
ssh $REMOTE_HOST "cd $APP_DIR && source .env.production && COMPOSE_PROJECT_NAME=nutripet APP_DOMAIN=$APP_DOMAIN LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL docker compose -f $COMPOSE_FILE up -d db"

# Wait for postgres to be ready
ssh $REMOTE_HOST "cd $APP_DIR && echo 'Waiting for postgres to be ready...' && sleep 10"

# Build new image
ssh $REMOTE_HOST "cd $APP_DIR && source .env.production && COMPOSE_PROJECT_NAME=nutripet APP_DOMAIN=$APP_DOMAIN LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL docker compose -f $COMPOSE_FILE build backend"

# Run migrations
ssh $REMOTE_HOST "cd $APP_DIR && source .env.production && COMPOSE_PROJECT_NAME=nutripet APP_DOMAIN=$APP_DOMAIN LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL DATABASE_HOST=db docker compose -f $COMPOSE_FILE run --rm backend rails db:migrate RAILS_ENV=production"

# Precompile assets
ssh $REMOTE_HOST "cd $APP_DIR && source .env.production && COMPOSE_PROJECT_NAME=nutripet APP_DOMAIN=$APP_DOMAIN LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL DATABASE_HOST=db docker compose -f $COMPOSE_FILE run --rm backend rails assets:precompile RAILS_ENV=production"

# Deploy with zero-downtime: wait for health check before stopping old container
ssh $REMOTE_HOST "cd $APP_DIR && source .env.production && COMPOSE_PROJECT_NAME=nutripet APP_DOMAIN=$APP_DOMAIN LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL docker compose -f $COMPOSE_FILE up -d --wait --no-deps backend"

echo "Deployment to $REMOTE_HOST finished."
