#!/bin/bash
# Prepares GPG and .env, then runs the backup. Works with compose mounts or plain env vars.
set -e

mkdir -p /root/.gnupg
chmod 700 /root/.gnupg

if [ -d /gnupg-host ]; then
  # Local compose run: copy the mounted keyring so gpg can write its lock files.
  cp -r /gnupg-host/. /root/.gnupg/
elif [ -n "$GPG_PUBLIC_KEYS_B64" ]; then
  # Hosted run (e.g. Coolify): import public keys from `gpg --export -a <ids> | base64 -w0`.
  echo "$GPG_PUBLIC_KEYS_B64" | base64 -d | gpg --batch --import
else
  echo "No GPG keys: mount ~/.gnupg at /gnupg-host or set GPG_PUBLIC_KEYS_B64." >&2
  exit 1
fi

# The scripts require a .env file; when none is mounted, real env vars are used instead.
touch .env

bash prep_backup.sh
bash backup.sh
