#!/bin/bash
set -e

cd /home/ubuntu/my-ente

/usr/bin/docker compose \
  --env-file .env \
  -f compose.yaml \
  up -d

