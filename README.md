# zeon-psql

A PostgreSQL 16 Docker setup with management scripts for creating databases and users.

## Quick Start

```bash
# Copy and configure environment
cp .env.example .env
# Edit .env with your credentials

# Start the database
docker-compose up -d

# Verify it's running
docker-compose ps
```

## Configuration

Create a `.env` file based on `.env.example`:

| Variable | Description |
|----------|-------------|
| `POSTGRES_USER` | Admin username |
| `POSTGRES_PASSWORD` | Admin password |
| `POSTGRES_DB` | Default database name |
| `PGHOST` | Host address (usually `localhost`) |

## Management Scripts

All scripts are in the `bash-scripts/` directory.

```bash
# Create a database + user combo
./bash-scripts/create-db-user.sh myapp

# Create just a user
./bash-scripts/create-user.sh api_user

# Create a database with an owner
./bash-scripts/create-database.sh api_db api_user

# List all databases/users
./bash-scripts/list-databases.sh
./bash-scripts/list-users.sh

# Grant privileges (all, readonly, readwrite)
./bash-scripts/grant-privileges.sh myapp readonly_user readonly

# Connect interactively
./bash-scripts/psql-connect.sh myapp

# Delete operations
./bash-scripts/delete-db-user.sh myapp
```

See [bash-scripts/README.md](bash-scripts/README.md) for full documentation.

## Backup & Restore

```bash
# Backup all databases
./backup.sh

# Restore from backup
./restore.sh backups/backup_file.sql
```

## Directory Structure

```
├── bash-scripts/     # Management scripts
├── backups/          # Backup files (gitignored)
├── init/             # SQL files run on first startup
├── pgdata/           # PostgreSQL data (gitignored)
├── docker-compose.yml
└── .env              # Configuration (gitignored)
```

## Connection Details

- **Host:** Value of `PGHOST` (default: `localhost`)
- **Port:** `5634`
- **Admin User:** Value of `POSTGRES_USER`
