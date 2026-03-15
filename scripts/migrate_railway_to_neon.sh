#!/usr/bin/env bash
set -euo pipefail

# Migration script: Railway PostgreSQL → Neon PostgreSQL
#
# Prerequisites:
#   - pg_dump and psql installed locally
#   - Railway connection string (find in Railway dashboard → your DB → Connect)
#   - Neon connection string (find in Neon console → your project → Connection Details)
#
# Usage:
#   export RAILWAY_URL="postgresql://user:pass@host:port/railway"
#   export NEON_URL="postgresql://user:pass@ep-xxx.region.neon.tech/neondb?sslmode=require"
#   bash scripts/migrate_railway_to_neon.sh

if [ -z "${RAILWAY_URL:-}" ]; then
  echo "Error: RAILWAY_URL is not set."
  echo "Export it from your Railway database dashboard, e.g.:"
  echo '  export RAILWAY_URL="postgresql://user:pass@host:port/railway"'
  exit 1
fi

if [ -z "${NEON_URL:-}" ]; then
  echo "Error: NEON_URL is not set."
  echo "Export it from your Neon project console, e.g.:"
  echo '  export NEON_URL="postgresql://user:pass@ep-xxx.region.neon.tech/neondb?sslmode=require"'
  exit 1
fi

DUMP_FILE="railway_dump_$(date +%Y%m%d_%H%M%S).sql"

echo "==> Dumping Railway database..."
pg_dump "$RAILWAY_URL" --no-owner --no-acl --clean --if-exists -f "$DUMP_FILE"
echo "    Saved to $DUMP_FILE"

echo "==> Importing into Neon..."
psql "$NEON_URL" -f "$DUMP_FILE"

echo "==> Done! Data migrated from Railway to Neon."
echo "    Dump file kept at: $DUMP_FILE"
