#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

ENV_FILE="${ENV_FILE:-$REPO_ROOT/infra/env/prod.env}"
COMPOSE_FILE="${COMPOSE_FILE:-$REPO_ROOT/docker-compose.yml}"
COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-fgu-ki-gever}"
DJANGO_SERVICE="${DJANGO_SERVICE:-backend}"
DJANGO_MIGRATE_CMD="${DJANGO_MIGRATE_CMD:-python manage.py migrate --noinput}"
DJANGO_COLLECTSTATIC_CMD="${DJANGO_COLLECTSTATIC_CMD:-python manage.py collectstatic --noinput}"

if [[ ! -f "$COMPOSE_FILE" ]]; then
  echo "[deploy] docker compose file not found: $COMPOSE_FILE" >&2
  exit 1
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "[deploy] env file not found: $ENV_FILE" >&2
  echo "[deploy] copy infra/env/prod.env.example to infra/env/prod.env and fill values" >&2
  exit 1
fi

cd "$REPO_ROOT"

compose_cmd=(docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" -p "$COMPOSE_PROJECT_NAME")

echo "[deploy] Pulling latest images..."
"${compose_cmd[@]}" pull

echo "[deploy] Building local images..."
"${compose_cmd[@]}" build

echo "[deploy] Starting or updating containers..."
"${compose_cmd[@]}" up -d --remove-orphans

echo "[deploy] Running Django migrations (${DJANGO_SERVICE})..."
"${compose_cmd[@]}" exec -T "$DJANGO_SERVICE" sh -c "$DJANGO_MIGRATE_CMD"

echo "[deploy] Collecting static assets (${DJANGO_SERVICE})..."
"${compose_cmd[@]}" exec -T "$DJANGO_SERVICE" sh -c "$DJANGO_COLLECTSTATIC_CMD"

echo "[deploy] Deployment completed successfully."
