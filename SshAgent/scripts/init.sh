#!/bin/bash
set -ex

echo "[INIT] Cleaning socket..."
rm -f /app/shared/agentsocket

echo "[INIT] Starting ssh-agent..."
eval "$(ssh-agent -s -a /app/shared/agentsocket)" || {
  echo "[ERROR] Failed to start ssh-agent"
  exit 1
}

echo "[INIT] Adding SSH keys..."
if [ -d "/opt/sshagent_keys" ]; then
  for key in /opt/sshagent_keys/*; do
    if [ -f "$key" ]; then
      echo "[INIT] Fixing permissions for $key"
      chmod 600 "$key"
      echo "[INIT] Adding key: $key"
      ssh-add "$key"
    else
      echo "[INIT] Skipping non-file: $key"
    fi
  done
else
  echo "[INIT] No key directory found."
fi

echo "[INIT] ssh-agent status:"
ssh-add -l || echo "[WARN] No identities found."

echo "[INIT] Startup complete. Holding container..."
exec tail -f /dev/null
