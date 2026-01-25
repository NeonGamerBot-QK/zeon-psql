#!/usr/bin/env bash
# Deletes a PostgreSQL user.
#
# Usage: ./delete-user.sh <username>
#   username: Required. The user to delete.
#
# Note: Will fail if the user owns any databases. Use delete-db-user.sh for that.

source "$(dirname "$0")/common.sh"
load_env

if [ -z "$1" ]; then
  print_error "Usage: $0 <username>"
  exit 1
fi

USER_NAME="$1"

print_warning "Deleting user '$USER_NAME'..."

psql_exec "DROP ROLE IF EXISTS \"$USER_NAME\";"

print_success "User '$USER_NAME' deleted!"
