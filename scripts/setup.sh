#!/bin/bash

set -e

echo "[+] Cloning and starting your homelab stack..."

docker compose pull
docker compose up -d

echo "[✓] Done!"
