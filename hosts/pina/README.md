# Ente Server Setup

All-in-one compose-file for self-hosting [Ente](https://ente.io), an open-source encrypted backup platform for photos and files. Automated deployment with Docker Compose + Caddy for reverse proxy and SSL.

## What's Included

- **Museum** - Core Ente server backend (port 8080)
- **Web** - Frontend applications including Photos, Albums, Cast, and Embed
- **PostgreSQL** - Persistent database storage
- **MinIO** - S3-compatible object storage
- **Socat** - Network routing for internal MinIO access
- **Caddy** - Reverse proxy with automatic SSL/TLS certificates

## Quick Start

### Step 1: Run Setup Wizard

```bash
bash <(curl -sSL https://raw.githubusercontent.com/polarhive/dots/main/hosts/pina/setup.sh)
```

The setup wizard will:
- Guide you through the Ente quickstart (if needed)
- Extract credentials from the generated config
- Prompt you for your domain names
- Create a `.env` file with all variables
- Remind you to configure DNS and open ports

### Step 2: Start Your Server

Once the wizard completes:

```bash
docker compose -f ente-compose.yml up -d
```

### Step 3: Access Your Instance

Open your browser to your configured domain (e.g., `https://photos.example.com`)

## Notes

- The `setup.sh` wizard handles all configuration interactively
- All data persists in Docker volumes
- Health checks ensure service availability
- Designed for production deployments with proper DNS and SSL
