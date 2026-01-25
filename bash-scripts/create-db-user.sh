#!/usr/bin/env bash
# Creates a new database AND user in one command.
# The user becomes the owner of the database with full privileges.
#
# Usage: ./create-db-user.sh [name]
#   name: Optional. Used for both db and user names. Defaults to "zeon_<random_suffix>"
#
# Returns: Database name, username, and password.

source "$(dirname "$0")/common.sh"
load_env

RAND_SUFFIX=$(generate_random 4)
NAME="${1:-zeon_$RAND_SUFFIX}"
DB_NAME="$NAME"
USER_NAME="$NAME"
PASSWORD=$(generate_random 16)

print_info "Creating database '$DB_NAME' and user '$USER_NAME'..."

# Create the user
psql_exec "CREATE ROLE \"$USER_NAME\" WITH LOGIN PASSWORD '$PASSWORD';"

# Create the database owned by the user
psql_exec "CREATE DATABASE \"$DB_NAME\" OWNER \"$USER_NAME\";"

# Grant all privileges on the database to the user
psql_exec "GRANT ALL PRIVILEGES ON DATABASE \"$DB_NAME\" TO \"$USER_NAME\";"

print_success "Database and user created successfully!"
echo "----------------------------------------"
echo "Database: $DB_NAME"
echo "Username: $USER_NAME"
echo "Password: $PASSWORD"
echo "Host:     $PGHOST"
echo "Port:     5634"
echo "----------------------------------------"
echo ""
echo "Connection string:"
echo "postgresql://$USER_NAME:$PASSWORD@$PGHOST:5634/$DB_NAME"
