# Plain Postgres server. Credentials come from POSTGRES_USER / POSTGRES_PASSWORD / POSTGRES_DB env vars.
# Persist /var/lib/postgresql/data with a volume, otherwise data is lost on redeploy.
FROM postgres:16

# Tools used by the backup scripts (gpg, rsync, scp, curl); pg_dumpall already ships with postgres.
RUN apt-get update \
    && apt-get install -y --no-install-recommends rsync openssh-client gnupg curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Backup scripts live in /app. Run with: docker exec -w /app <container> bash backup-entrypoint.sh
WORKDIR /app
COPY backup.sh prep_backup.sh backup-entrypoint.sh ./

# Init scripts run once, only when the data directory is empty.
COPY init/ /docker-entrypoint-initdb.d/

EXPOSE 5432
