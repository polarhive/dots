# Ente Self-Host Wizard

An interactive setup script for self-hosting [Ente](https://ente.io), an open-source encrypted photo backup service. It handles domain configuration, DNS validation, secret generation, and creates a single Docker Compose setup with Caddy for SSL termination.

## Quick Start

```bash
bash <(curl -sSL https://raw.githubusercontent.com/polarhive/dots/main/hosts/pina/setup.sh)
```

The script prompts for domains (required: Photos and S3; optional: Accounts, Albums, Auth, Cast, Share, Embed), validates DNS resolution, generates secure secrets, and creates a `my-ente` directory with Docker Compose and Caddy configurations. After setup, it starts the services, provides the login URL, and fetches the verification code for immediate sign-in.

## Systemd Service

   ```bash
   sudo cp my-ente.service /etc/systemd/system/
   sudo cp my-ente-start.sh /usr/local/bin/
   sudo chmod +x /usr/local/bin/my-ente-start.sh
   ```
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable --now my-ente.service
   ```
