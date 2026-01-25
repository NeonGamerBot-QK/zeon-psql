#!/usr/bin/env bash
# Changes the password for a PostgreSQL user.
#
# Usage: ./change-password.sh <username> [new_password]
#   username:     Required. The user whose password to change.
#   new_password: Optional. If not provided, a random password is generated.

source "$(dirname "$0")/common.sh"
load_env

if [ -z "$1" ]; then
  print_error "Usage: $0 <username> [new_password]"
  exit 1
fi

USER_NAME="$1"
PASSWORD="${2:-$(generate_random 16)}"

print_info "Changing password for user '$USER_NAME'..."

psql_exec "ALTER ROLE \"$USER_NAME\" WITH PASSWORD '$PASSWORD';"

print_success "Password changed!"
echo "----------------------------------------"
echo "Username: $USER_NAME"
echo "Password: $PASSWORD"
echo "----------------------------------------"
