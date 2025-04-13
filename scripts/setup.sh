#!/bin/bash

# Setup script for homelab Docker installation
set -e

echo "Homelab Docker Setup"
echo "===================="
echo

# Create necessary directories
echo "Creating directory structure..."
mkdir -p config/traefik/config config/tailscale/state data/frigate/database data/portainer
echo "✓ Directory structure created"
echo

# Check if /mnt/frigate exists
if [ ! -d "/mnt/frigate" ]; then
    echo "⚠ /mnt/frigate mount point not found."
    echo "   You need to create and mount this directory for Frigate recordings."
    echo "   Example: sudo mkdir -p /mnt/frigate && sudo chown $(id -u):$(id -g) /mnt/frigate"
    echo "   Then mount your storage device to this location or add it to /etc/fstab"
else
    echo "✓ /mnt/frigate mount point found"
fi
echo

# Create .env file from template
if [ ! -f .env ]; then
    echo "Setting up environment variables..."
    cp .env.example .env
    
    # Ask for domain name
    read -p "Domain name (default: ewaldbervoets.com): " domain_name
    domain_name=${domain_name:-ewaldbervoets.com}
    sed -i "s/DOMAIN_NAME=.*/DOMAIN_NAME=$domain_name/" .env
    
    # Ask for timezone
    read -p "Timezone (default: Europe/Amsterdam): " timezone
    timezone=${timezone:-Europe/Amsterdam}
    sed -i "s|TZ=.*|TZ=$timezone|" .env
    
    # Generate Traefik dashboard credentials
    echo "Setting up Traefik dashboard credentials..."
    read -p "Username for Traefik dashboard (default: admin): " traefik_user
    traefik_user=${traefik_user:-admin}
    
    read -s -p "Password for Traefik dashboard: " traefik_pass
    echo
    
    # Check if htpasswd is installed
    if ! command -v htpasswd &> /dev/null; then
        echo "htpasswd not found. Installing apache2-utils..."
        sudo apt-get update && sudo apt-get install -y apache2-utils
    fi
    
    # Generate hashed password and escape for docker-compose
    traefik_auth=$(htpasswd -nb $traefik_user $traefik_pass | sed 's/\$/\$\$/g')
    sed -i "s|TRAEFIK_DASHBOARD_AUTH=.*|TRAEFIK_DASHBOARD_AUTH=$traefik_auth|" .env
    
    echo "✓ Environment file created"
else
    echo "⚠ .env file already exists. Skipping configuration."
fi
echo

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "⚠ Docker not found. Please install Docker and Docker Compose before proceeding."
    echo "   See: https://docs.docker.com/engine/install/"
else
    echo "✓ Docker is installed"
fi

# Check if Tailscale is installed
if ! command -v tailscale &> /dev/null; then
    echo "⚠ Tailscale not found. Please install Tailscale before proceeding."
    echo "   See: https://tailscale.com/download"
else
    echo "✓ Tailscale is installed"
    
    # Check if Tailscale is running and authenticated
    if ! tailscale status &> /dev/null; then
        echo "⚠ Tailscale is not running or not authenticated. Please run:"
        echo "   sudo tailscale up"
    else
        echo "✓ Tailscale is running"
        
        # Display Tailscale IP
        tailscale_ip=$(tailscale ip -4)
        echo "ℹ Your Tailscale IP is: $tailscale_ip"
    fi
fi
echo

echo "Setup completed successfully!"