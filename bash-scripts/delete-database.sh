#!/usr/bin/env bash
# Deletes a PostgreSQL database.
#
# Usage: ./delete-database.sh <db_name>
#   db_name: Required. The database to delete.
#
# Warning: This action is irreversible!

source "$(dirname "$0")/common.sh"
load_env

if [ -z "$1" ]; then
  print_error "Usage: $0 <db_name>"
  exit 1
fi

DB_NAME="$1"

print_warning "Deleting database '$DB_NAME'..."

# Terminate all connections to the database first
psql_exec "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DB_NAME' AND pid <> pg_backend_pid();" 2> /dev/null || true

psql_exec "DROP DATABASE IF EXISTS \"$DB_NAME\";"

print_success "Database '$DB_NAME' deleted!"
