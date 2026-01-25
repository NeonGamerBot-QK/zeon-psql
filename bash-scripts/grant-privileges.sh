#!/usr/bin/env bash
# Grants privileges on a database to a user.
#
# Usage: ./grant-privileges.sh <db_name> <username> [privilege_type]
#   db_name:        Required. The database to grant access to.
#   username:       Required. The user to grant privileges to.
#   privilege_type: Optional. "all" (default), "readonly", or "readwrite"

source "$(dirname "$0")/common.sh"
load_env

if [ -z "$1" ] || [ -z "$2" ]; then
  print_error "Usage: $0 <db_name> <username> [privilege_type]"
  echo "  privilege_type: all (default), readonly, readwrite"
  exit 1
fi

DB_NAME="$1"
USER_NAME="$2"
PRIV_TYPE="${3:-all}"

print_info "Granting '$PRIV_TYPE' privileges on '$DB_NAME' to '$USER_NAME'..."

case "$PRIV_TYPE" in
  all)
    psql_exec "GRANT ALL PRIVILEGES ON DATABASE \"$DB_NAME\" TO \"$USER_NAME\";"
    ;;
  readonly)
    psql_exec "GRANT CONNECT ON DATABASE \"$DB_NAME\" TO \"$USER_NAME\";"
    # Connect to the specific database to grant schema permissions
    PGPASSWORD="$POSTGRES_PASSWORD" psql "host=$PGHOST port=5634 user=$POSTGRES_USER dbname=$DB_NAME" -v ON_ERROR_STOP=1 \
      -c "GRANT USAGE ON SCHEMA public TO \"$USER_NAME\";" \
      -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"$USER_NAME\";" \
      -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO \"$USER_NAME\";"
    ;;
  readwrite)
    psql_exec "GRANT CONNECT ON DATABASE \"$DB_NAME\" TO \"$USER_NAME\";"
    PGPASSWORD="$POSTGRES_PASSWORD" psql "host=$PGHOST port=5634 user=$POSTGRES_USER dbname=$DB_NAME" -v ON_ERROR_STOP=1 \
      -c "GRANT USAGE ON SCHEMA public TO \"$USER_NAME\";" \
      -c "GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO \"$USER_NAME\";" \
      -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO \"$USER_NAME\";"
    ;;
  *)
    print_error "Unknown privilege type: $PRIV_TYPE"
    exit 1
    ;;
esac

print_success "Privileges granted!"
