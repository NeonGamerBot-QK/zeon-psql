#!/usr/bin/env bash
# Creates a new PostgreSQL database with an optional owner.
#
# Usage: ./create-database.sh [db_name] [owner]
#   db_name: Optional. Defaults to "zeon_<random_suffix>"
#   owner:   Optional. The user who will own the database.
#
# Returns: The database name and owner information.

source "$(dirname "$0")/common.sh"
load_env

RAND_SUFFIX=$(generate_random 4)
DB_NAME="${1:-zeon_$RAND_SUFFIX}"
OWNER="${2:-}"

print_info "Creating database '$DB_NAME'..."

if [ -n "$OWNER" ]; then
  psql_exec "CREATE DATABASE \"$DB_NAME\" OWNER \"$OWNER\";"
  psql_exec "GRANT ALL PRIVILEGES ON DATABASE \"$DB_NAME\" TO \"$OWNER\";"
  print_success "Database created with owner '$OWNER'!"
else
  psql_exec "CREATE DATABASE \"$DB_NAME\";"
  print_success "Database created!"
fi

echo "----------------------------------------"
echo "Database: $DB_NAME"
[ -n "$OWNER" ] && echo "Owner:    $OWNER"
echo "----------------------------------------"
