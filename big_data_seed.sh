#!/bin/bash
set -e

# Load environment variables safely
if [ ! -f .env ]; then
  echo ".env file not found!"
  exit 1
fi

# Convert Windows line endings if any
sed -i 's/\r$//' .env

# Export all variables
set -a
source .env
set +a

# Check required variable
: "${PSQL_DB_URL:?Need PSQL_DB_URL in .env}"

echo "Seeding database via $PSQL_DB_URL ..."

# Run SQL to create big table and insert ~5GB of data
psql "$PSQL_DB_URL" <<'EOF'
DROP TABLE IF EXISTS bigtable;
CREATE TABLE bigtable (
    id BIGSERIAL PRIMARY KEY,
    filler TEXT
);

-- ~5GB of random data (500k rows × ~10 KB per row)
INSERT INTO bigtable (filler)
SELECT repeat(md5(random()::text), 80)
FROM generate_series(1, 500000);
EOF

echo "Seeding complete!"
