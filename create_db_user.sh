#!/usr/bin/env bash
set -e

# Load environment variables from .env
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo ".env file not found!"
  exit 1
fi

# Generate random 4-character suffix
RAND_SUFFIX=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c4)

# Default database and user names
DB_NAME="${1:-zeon_$RAND_SUFFIX}"
USER_NAME="${2:-zeon_$RAND_SUFFIX}"

# Generate a random 16-character password
PASSWORD=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c16)

echo "Creating database '$DB_NAME' and user '$USER_NAME'..."

# Base psql connection string
PSQL_CONN="host=$PGHOST port=5634 user=$POSTGRES_USER dbname=$POSTGRES_DB"

# 1️⃣ Create the user
PGPASSWORD="$POSTGRES_PASSWORD" psql "$PSQL_CONN" -v ON_ERROR_STOP=1 \
  -c "CREATE ROLE \"$USER_NAME\" WITH LOGIN PASSWORD '$PASSWORD';"

# 2️⃣ Create the database owned by the user
PGPASSWORD="$POSTGRES_PASSWORD" psql "$PSQL_CONN" -v ON_ERROR_STOP=1 \
  -c "CREATE DATABASE \"$DB_NAME\" OWNER \"$USER_NAME\";"

# 3️⃣ Grant all privileges on the database to the user
PGPASSWORD="$POSTGRES_PASSWORD" psql "$PSQL_CONN" -v ON_ERROR_STOP=1 \
  -c "GRANT ALL PRIVILEGES ON DATABASE \"$DB_NAME\" TO \"$USER_NAME\";"

# 4️⃣ Output credentials
echo "✅ Done!"
echo "Database: $DB_NAME"
echo "User:     $USER_NAME"
echo "Password: $PASSWORD"
