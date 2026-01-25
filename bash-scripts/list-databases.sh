#!/usr/bin/env bash
# Lists all PostgreSQL databases.
#
# Usage: ./list-databases.sh

source "$(dirname "$0")/common.sh"
load_env

print_info "Listing all databases..."
echo ""

PGPASSWORD="$POSTGRES_PASSWORD" psql "$(get_psql_conn)" -c "\l"
