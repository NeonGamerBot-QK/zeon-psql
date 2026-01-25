#!/usr/bin/env bash
# Opens an interactive psql session connected to the database.
#
# Usage: ./psql-connect.sh [db_name]
#   db_name: Optional. Database to connect to. Defaults to the main database.

source "$(dirname "$0")/common.sh"
load_env

DB_NAME="${1:-$POSTGRES_DB}"

print_info "Connecting to database '$DB_NAME'..."

PGPASSWORD="$POSTGRES_PASSWORD" psql "host=$PGHOST port=5634 user=$POSTGRES_USER dbname=$DB_NAME"
