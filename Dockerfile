# Plain Postgres server. Credentials come from POSTGRES_USER / POSTGRES_PASSWORD / POSTGRES_DB env vars.
# Persist /var/lib/postgresql/data with a volume, otherwise data is lost on redeploy.
FROM postgres:16

# Init scripts run once, only when the data directory is empty.
COPY init/ /docker-entrypoint-initdb.d/

EXPOSE 5432
