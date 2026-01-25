#!/usr/bin/env bash
# Common utilities and environment loading for all scripts

set -e

# Resolve the project root directory (parent of bash-scripts)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load environment variables from .env file
load_env() {
  if [ -f "$PROJECT_ROOT/.env" ]; then
    export $(grep -v '^#' "$PROJECT_ROOT/.env" | xargs)
  else
    echo "Error: .env file not found at $PROJECT_ROOT/.env"
    exit 1
  fi
}

# Base psql connection string for admin operations
get_psql_conn() {
  echo "host=$PGHOST port=5634 user=$POSTGRES_USER dbname=$POSTGRES_DB"
}

# Execute a psql command as the admin user
psql_exec() {
  local query="$1"
  PGPASSWORD="$POSTGRES_PASSWORD" psql "$(get_psql_conn)" -v ON_ERROR_STOP=1 -c "$query"
}

# Execute a psql query and return results (no headers, aligned)
psql_query() {
  local query="$1"
  PGPASSWORD="$POSTGRES_PASSWORD" psql "$(get_psql_conn)" -v ON_ERROR_STOP=1 -t -A -c "$query"
}

# Generate a random alphanumeric string of specified length
generate_random() {
  local length="${1:-16}"
  tr -dc 'A-Za-z0-9' < /dev/urandom | head -c"$length"
}

# Print a colored status message
print_success() { echo -e "\033[0;32m✅ $1\033[0m"; }
print_error() { echo -e "\033[0;31m❌ $1\033[0m"; }
print_info() { echo -e "\033[0;34mℹ️  $1\033[0m"; }
print_warning() { echo -e "\033[0;33m⚠️  $1\033[0m"; }
