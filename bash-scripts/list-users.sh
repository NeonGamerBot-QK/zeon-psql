#!/usr/bin/env bash
# Lists all PostgreSQL users/roles.
#
# Usage: ./list-users.sh

source "$(dirname "$0")/common.sh"
load_env

print_info "Listing all users..."
echo ""

PGPASSWORD="$POSTGRES_PASSWORD" psql "$(get_psql_conn)" -c "\du"
