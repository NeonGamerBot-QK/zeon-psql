# Same major version as the server so pg_dumpall can talk to it.
FROM postgres:16

# Tools used by prep_backup.sh (gpg, pg_dumpall) and backup.sh (rsync, scp, curl).
RUN apt-get update \
    && apt-get install -y --no-install-recommends rsync openssh-client gnupg curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Scripts source .env and use ./backups, so they must run from here.
WORKDIR /app

COPY backup.sh prep_backup.sh backup-entrypoint.sh ./

ENTRYPOINT ["bash", "backup-entrypoint.sh"]
