bash prep_backup.sh

# now ac script
#!/bin/bash
set -e

# --- Load environment variables ---
if [ -f .env ]; then
    sed -i 's/\r$//' .env
    set -a
    source .env
    set +a
else
    echo ".env file not found!"
    exit 1
fi
START_TIME=$(date +%s)
BACKUP_DIR="./backups"
LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/*.sql.gz.gpg 2>/dev/null | head -1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "No backup files found in $BACKUP_DIR"
    exit 1
fi

echo "Uploading latest backup: $LATEST_BACKUP"

# --- 1️⃣ Upload via rsync to S3-like endpoints ---
if [ -n "$S3_RSYNC_URLS" ]; then
    IFS=',' read -ra S3_URL_ARRAY <<< "$S3_RSYNC_URLS"
    for url in "${S3_URL_ARRAY[@]}"; do
        echo "Uploading to $url/latest.sql.gz.gpg via rsync..."
        rsync -avz "$LATEST_BACKUP" "$url/latest.sql.gz.gpg" || echo "❌ rsync to $url failed, continuing..."
    done
else
    echo "No S3 rsync URLs provided, skipping rsync upload"
fi

# --- 2️⃣ Upload via SCP to SSH destinations with optional ports ---
if [ -n "$SCP_DESTINATIONS" ]; then
    IFS=';' read -ra SCP_ARRAY <<< "$SCP_DESTINATIONS"
    for dest in "${SCP_ARRAY[@]}"; do
        IFS=':' read -r userhost path port <<< "$dest"
        remote_file="$path/latest.sql.gz.gpg"

        if [ -n "$port" ]; then
            echo "Uploading to $userhost:$remote_file on port $port via scp..."
            scp -i "$SCP_KEY" -P "$port" "$LATEST_BACKUP" "$userhost:$remote_file" || echo "❌ scp to $userhost failed, continuing..."
        else
            echo "Uploading to $userhost:$remote_file via scp..."
            scp -i "$SCP_KEY" "$LATEST_BACKUP" "$userhost:$remote_file" || echo "❌ scp to $userhost failed, continuing..."
        fi
    done
else
    echo "No SCP destinations provided, skipping SCP upload"
fi

echo "All uploads finished. The latest backup is now stored as latest.sql.gz.gpg."
# notify via slack
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
BACKUP_SIZE=$(du -h "$LATEST_BACKUP" | cut -f1)

 curl -s -X POST -H "Authorization: Bearer $SLACK_TOKEN" \
       -H "Content-Type: application/json" \
       -d "{\"channel\":\"$CHANNEL_ID\",\"text\":\"mrrp, backups complete! latest backup size is: $BACKUP_SIZE and it took $ELAPSED seconds to transfer to servers and run this script!\"}" \
       https://slack.com/api/chat.postMessage > /dev/null