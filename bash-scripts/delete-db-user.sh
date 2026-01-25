#!/usr/bin/env bash
# Deletes both a database AND its associated user.
#
# Usage: ./delete-db-user.sh <name>
#   name: Required. Used for both the database and user name.
#
# Warning: This action is irreversible!

source "$(dirname "$0")/common.sh"
load_env

if [ -z "$1" ]; then
  print_error "Usage: $0 <name>"
  exit 1
fi

NAME="$1"
DB_NAME="$NAME"
USER_NAME="$NAME"

print_warning "Deleting database '$DB_NAME' and user '$USER_NAME'..."

# Terminate all connections to the database first
psql_exec "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DB_NAME' AND pid <> pg_backend_pid();" 2>/dev/null || true

# Drop the database
psql_exec "DROP DATABASE IF EXISTS \"$DB_NAME\";"

# Drop the user
psql_exec "DROP ROLE IF EXISTS \"$USER_NAME\";"

print_success "Database '$DB_NAME' and user '$USER_NAME' deleted!"
