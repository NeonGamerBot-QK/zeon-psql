# AGENTS.md

## Project Overview

PostgreSQL 16 Docker setup with bash management scripts for database/user administration.

## Tech Stack

- PostgreSQL 16 (Docker)
- Bash scripts
- Docker Compose

## Project Structure

- `bash-scripts/` - All management scripts (create/delete users, databases, etc.)
- `init/` - SQL files executed on first container startup
- `pgdata/` - PostgreSQL data directory (gitignored)
- `backups/` - Backup files (gitignored)

## Key Files

- `docker-compose.yml` - Main PostgreSQL service definition
- `.env` - Environment configuration (POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB, PGHOST)
- `bash-scripts/common.sh` - Shared utilities for all scripts

## Commands

```bash
# Start database
docker-compose up -d

# Stop database
docker-compose down

# View logs
docker-compose logs -f postgres

# Backup
./backup.sh

# Restore
./restore.sh <backup_file>
```

## Port

PostgreSQL runs on port `5634` (mapped from container's 5432).

## Script Conventions

- All scripts source `bash-scripts/common.sh` for shared utilities
- Scripts use `set -e` for error handling
- Environment loaded from `.env` in project root
- Use kebab-case for script names (e.g., `create-db-user.sh`)
