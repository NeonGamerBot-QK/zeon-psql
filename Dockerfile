# Same major version as the server so pg_dumpall can talk to it.
FROM postgres:16

# Tools used by prep_backup.sh (gpg, pg_dumpall) and backup.sh (rsync, scp, curl).
RUN apt-get update \
    && apt-get install -y --no-install-recommends rsync openssh-client gnupg curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Scripts source .env and use ./backups, so they must run from here.
WORKDIR /app

# Copy the host's GPG keyring (mounted read-only) so gpg can write its lock files, then run the backup.
ENTRYPOINT ["bash", "-c", "mkdir -p /root/.gnupg && cp -r /gnupg-host/. /root/.gnupg/ && chmod 700 /root/.gnupg && bash prep_backup.sh && bash backup.sh"]
