#!/bin/bash
set -e

# --- Load environment variables safely ---
if [ -f .env ]; then
    # Convert line endings just in case
    sed -i 's/\r$//' .env
    set -a
    source .env
    set +a
else
    echo ".env file not found!"
    exit 1
fi

# --- Check required variables ---
: "${PSQL_DB_URL:?PSQL_DB_URL must be set in .env}"
: "${POSTGRES_USER:?POSTGRES_USER must be set in .env}"
: "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD must be set in .env}"
: "${POSTGRES_DB:?POSTGRES_DB must be set in .env}"

# --- Backup file to restore ---
BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup-file.sql.gz.gpg>"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Backup file $BACKUP_FILE does not exist"
    exit 1
fi

# --- Parse PSQL_DB_URL if needed ---
# Example: postgresql://user:pass@host:port/db
# Or fallback to env variables
PSQL_HOST=$(echo "$PSQL_DB_URL" | sed -E 's|postgresql://[^:]+:[^@]+@([^:/]+).*|\1|')
PSQL_PORT=$(echo "$PSQL_DB_URL" | sed -E 's|postgresql://[^:]+:[^@]+@[^:/]+:([0-9]+).*|\1|')
PSQL_DB=$(echo "$PSQL_DB_URL" | sed -E 's|postgresql://[^:]+:[^@]+@[^:/]+(:[0-9]+)?/([^?]+).*|\2|')

# --- Export password for psql ---
export PGPASSWORD=$POSTGRES_PASSWORD

echo "Restoring backup $BACKUP_FILE to $PSQL_DB on $PSQL_HOST:$PSQL_PORT as $POSTGRES_USER..."

# --- Restore: decrypt -> decompress -> restore ---
gpg --decrypt "$BACKUP_FILE" | gunzip | psql -h "$PSQL_HOST" -p "${PSQL_PORT:-5432}" -U "$POSTGRES_USER" -d "$PSQL_DB"

echo "Restore complete!"
