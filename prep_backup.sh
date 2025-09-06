#!/bin/bash
set -e

# --- Load environment ---
set -a
source .env
set +a

: "${PSQL_DB_URL:?Need PSQL_DB_URL in .env}"
: "${BACKUP_DIR:=./backups}"

mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="$BACKUP_DIR/backup_${TIMESTAMP}.sql.gz.gpg"

echo "Parsing PSQL_DB_URL..."

# Extract components from URL: postgresql://user:pass@host:port/db
proto="$(echo $PSQL_DB_URL | grep :// | sed -e's,^\(.*://\).*,\1,g')"
url_no_proto="${PSQL_DB_URL/$proto/}"
userpass_hostport_db="$(echo $url_no_proto | sed 's/@/\ /')"
USER_PASS="$(echo $userpass_hostport_db | awk '{print $1}')"
HOST_PORT_DB="$(echo $userpass_hostport_db | awk '{print $2}')"

PGUSER="$(echo $USER_PASS | cut -d':' -f1)"
PGPASSWORD="$(echo $USER_PASS | cut -d':' -f2)"
PGHOST="$(echo $HOST_PORT_DB | cut -d':' -f1)"
PGPORT_DB="$(echo $HOST_PORT_DB | cut -d':' -f2)"
PGPORT="$(echo $PGPORT_DB | cut -d'/' -f1)"
PGDATABASE="$(echo $PGPORT_DB | cut -d'/' -f2)"

export PGPASSWORD

echo "Backing up ALL databases from $PGHOST:$PGPORT as $PGUSER ..."

# pg_dumpall → compress → encrypt
pg_dumpall -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" \
  | gzip \
  | gpg --batch --yes --trust-model always \
        -e -r "zeon@saahild.com" \
        -r "neon@saahild.com" \
        -o "$FILENAME"

unset PGPASSWORD

echo "Backup complete: $FILENAME"
