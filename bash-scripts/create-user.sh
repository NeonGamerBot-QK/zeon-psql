#!/usr/bin/env bash
# Creates a new PostgreSQL user with a randomly generated password.
#
# Usage: ./create-user.sh [username]
#   username: Optional. Defaults to "zeon_<random_suffix>"
#
# Returns: The username and generated password.

source "$(dirname "$0")/common.sh"
load_env

RAND_SUFFIX=$(generate_random 4)
USER_NAME="${1:-zeon_$RAND_SUFFIX}"
PASSWORD=$(generate_random 16)

print_info "Creating user '$USER_NAME'..."

psql_exec "CREATE ROLE \"$USER_NAME\" WITH LOGIN PASSWORD '$PASSWORD';"

print_success "User created successfully!"
echo "----------------------------------------"
echo "Username: $USER_NAME"
echo "Password: $PASSWORD"
echo "----------------------------------------"
