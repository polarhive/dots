# Ente Server Setup

All-in-one setup script for self-hosting [Ente](https://ente.io), an open-source encrypted backup platform for photos and files. Automated deployment with Docker Compose + Caddy for reverse proxy and SSL.

## What's Included

- **Museum** - Core Ente server backend (port 8080)
- **Web** - Frontend applications including Photos, Albums, Cast, and Embed
- **PostgreSQL** - Persistent database storage
- **MinIO** - S3-compatible object storage
- **Socat** - Network routing for internal MinIO access
- **Caddy** - Reverse proxy with automatic SSL/TLS certificates

## Quick Start

Run the self-contained setup script:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/polarhive/dots/main/hosts/pina/setup.sh)
```

This will create a `my-ente` directory with your configuration.

```bash
cd my-ente
docker compose up -d
```

Open your browser to your configured domain (e.g. `https://photos.example.com`)

## Notes

- All data persists in Docker volumes
- Health checks ensure service availability
- Designed for deployments with proper DNS and SSL
