#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

ENV_FILE="${ENV_FILE:-$REPO_ROOT/infra/env/prod.env}"
COMPOSE_FILE="${COMPOSE_FILE:-$REPO_ROOT/docker-compose.yml}"
COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-fgu-ki-gever}"

DB_SERVICE="${DB_SERVICE:-db}"
DB_NAME="${DB_NAME:-}"
DB_USER="${DB_USER:-}"
BACKUP_DIR="${BACKUP_DIR:-$REPO_ROOT/backups}"
TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"
OUT_FILE="$BACKUP_DIR/db-$TIMESTAMP.sql.gz"

if [[ ! -f "$COMPOSE_FILE" ]]; then
  echo "[backup] docker compose file not found: $COMPOSE_FILE" >&2
  exit 1
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "[backup] env file not found: $ENV_FILE" >&2
  echo "[backup] copy infra/env/prod.env.example to infra/env/prod.env and fill values" >&2
  exit 1
fi

if [[ -z "$DB_NAME" || -z "$DB_USER" ]]; then
  echo "[backup] DB_NAME and DB_USER must be set (e.g. in $ENV_FILE)" >&2
  exit 1
fi

mkdir -p "$BACKUP_DIR"
cd "$REPO_ROOT"

compose_cmd=(docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" -p "$COMPOSE_PROJECT_NAME")

echo "[backup] Creating PostgreSQL backup from service '$DB_SERVICE'..."
"${compose_cmd[@]}" exec -T "$DB_SERVICE" pg_dump -U "$DB_USER" "$DB_NAME" | gzip -c > "$OUT_FILE"

echo "[backup] Backup written to: $OUT_FILE"
