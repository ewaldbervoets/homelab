#!/bin/bash

set -e

echo "[+] Cloning and starting your homelab stack..."

docker compose pull
docker compose up -d

echo "[✓] Done! You can now access your services:"
echo " - Frigate: http://frigate.homelab.local"
echo " - Portainer: http://portainer.homelab.local"
echo " - Pi-hole: http://pihole.homelab.local"
