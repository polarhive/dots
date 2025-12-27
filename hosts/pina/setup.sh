#!/usr/bin/env bash
if [[ -z "${BASH_VERSION:-}" ]]; then
  echo "Please run with bash: bash $0 $@"
  exit 1
fi
set -euo pipefail

# Ente quick wizard: generates .env and a single compose.yaml with your preferences.
# Self-contained: no external downloads. Designed for macOS/Linux.

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

say() { printf "%b\n" "$1"; }

require() {
  local cmd="$1" msg="$2"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    say "${RED}ERROR:${NC} $msg"
    exit 1
  fi
}

docker_compose_version_ok() {
  if ! command -v docker >/dev/null 2>&1; then
    return 1
  fi
  local v
  v=$(docker compose version --short 2>/dev/null || true)
  [[ -z "$v" ]] && return 1
  local maj min
  maj=$(echo "$v" | cut -d. -f1)
  min=$(echo "$v" | cut -d. -f2)
  [[ "$maj" -gt 2 || ( "$maj" -eq 2 && "$min" -ge 30 ) ]]
}

header() {
  say "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  say "${BLUE}     Ente Server Quick Wizard${NC}"
  say "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

gen_user_suffix() { head -c 6 /dev/urandom | base64 | tr -d '\n'; }
gen_password() { head -c 21 /dev/urandom | base64 | tr -d '\n'; }
gen_key() { head -c 32 /dev/urandom | base64 | tr -d '\n'; }
gen_hash() { head -c 64 /dev/urandom | base64 | tr -d '\n'; }
gen_jwt_secret() { head -c 32 /dev/urandom | base64 | tr -d '\n' | tr '+/' '-_'; }

ask_bool() {
  local key="$1" prompt="$2" default="${3:-false}" value=""
  local current="${!key-}"
  local def="${current:-$default}"
  local yn_def
  if [[ "$def" == true ]]; then yn_def="y"; else yn_def="N"; fi
  read -r -p "$prompt [y/${yn_def}]: " value || true
  value=${value:-$def}
  case "$value" in
    [Yy][Ee][Ss]|[Yy]|true|TRUE) value=true ;;
    *) value=false ;;
  esac
  printf -v "$key" "%s" "$value"
}

load_env() {
  local file=".env"
  [[ -f "$file" ]] || return 0
  while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^\s*# ]] && continue
    if [[ "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then
      eval "$line"
    fi
  done < "$file"
}

ask() {
  local key="$1" prompt="$2" default="${3-}" value=""
  local current="${!key-}"
  local def="${current:-$default}"
  if [[ -n "$def" ]]; then
    read -r -p "$prompt [$def]: " value || true
    value="${value:-$def}"
  else
    read -r -p "$prompt: " value || true
  fi
  printf -v "$key" "%s" "$value"
}

ask_domain_input() {
  local var_name="$1" label="$2"
  local val=""
  read -r -p "Enable $label domain [subdomain.domain.tld]: " val || true
  if [[ -n "$val" ]] && [[ ! "$val" =~ ^https?:// ]]; then
    printf -v "$var_name" "%s" "$val"
  else
    printf -v "$var_name" ""
  fi
}

update_env() {
  local key="$1" val="$2" tmp
  tmp=$(mktemp)
  if [[ -f .env ]]; then
    awk -v k="$key" -v v="$val" 'BEGIN{u=0} $0 ~ "^"k"=" {print k"="v; u=1; next} {print} END{if(!u) print k"="v}' .env > "$tmp"
  else
    printf "%s=%s\n" "$key" "$val" > "$tmp"
  fi
  mv "$tmp" .env
}

generate_compose() {
  {
    cat <<'YAML'
services:
  museum:
    image: ghcr.io/ente-io/server
    ports:
      - 8080:8080
    depends_on:
      postgres:
        condition: service_healthy
    command:
      - sh
      - -c
      - |
        {
          cat <<EOF
        internal:
          admin: ${MUSEUM_ADMIN}
          disable-registration: ${MUSEUM_DISABLE_REGISTRATION}
        db:
          host: postgres
          port: 5432
          name: ${POSTGRES_DB}
          user: ${POSTGRES_USER}
          password: ${POSTGRES_PASSWORD}
        s3:
          are_local_buckets: true
          use_path_style_urls: false
          b2-eu-cen:
            key: ${MINIO_ROOT_USER}
            secret: ${MINIO_ROOT_PASSWORD}
            endpoint: ${ENTE_S3_ENDPOINT}
            region: ${ENTE_S3_REGION}
            bucket: ${ENTE_S3_BUCKET}
        apps:
        EOF
          if [ -n "${ENTE_PHOTOS_DOMAIN}" ]; then printf "  photos: https://%s\n" "${ENTE_PHOTOS_DOMAIN}"; fi
          if [ -n "${ENTE_ALBUMS_DOMAIN}" ]; then printf "  public-albums: https://%s\n" "${ENTE_ALBUMS_DOMAIN}"; fi
          if [ -n "${ENTE_CAST_DOMAIN}" ]; then printf "  cast: https://%s\n" "${ENTE_CAST_DOMAIN}"; fi
          if [ -n "${ENTE_EMBED_DOMAIN}" ]; then printf "  embed-albums: https://%s\n" "${ENTE_EMBED_DOMAIN}"; fi
          if [ -n "${ENTE_ACCOUNTS_DOMAIN}" ]; then printf "  accounts: https://%s\n" "${ENTE_ACCOUNTS_DOMAIN}"; fi
          if [ -n "${ENTE_SHARE_DOMAIN}" ]; then printf "  public-locker: https://%s\n" "${ENTE_SHARE_DOMAIN}"; fi
          cat <<EOF
        key:
          encryption: ${MUSEUM_ENCRYPTION_KEY}
          hash: ${MUSEUM_HASH_KEY}
        jwt:
          secret: ${MUSEUM_JWT_SECRET}
        EOF
        } > ./museum.yaml
        exec /museum
    volumes:
      - ./data:/data:ro
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:8080/ping"]
      interval: 60s
      timeout: 5s
      retries: 3
      start_period: 120s

  socat:
    image: alpine/socat
    network_mode: service:museum
    depends_on: [museum]
    command: "TCP-LISTEN:3200,fork,reuseaddr TCP:minio:3200"

  web:
    image: ghcr.io/ente-io/web
    depends_on:
      museum:
        condition: service_healthy
YAML
    if ((${#WEB_PORT_LINES[@]})); then
      echo "    ports:"
      printf '%s\n' "${WEB_PORT_LINES[@]}"
    fi
    cat <<'YAML'
    env_file:
      - .env

  postgres:
    image: postgres:15
    env_file:
      - .env
    healthcheck:
      test: pg_isready -q -d ${POSTGRES_DB} -U ${POSTGRES_USER}
      start_period: 40s
      start_interval: 1s
    volumes:
      - postgres-data:/var/lib/postgresql/data

  minio:
    image: minio/minio
    ports:
      - 3200:3200
    env_file:
      - .env
    command: server /data --address ":3200" --console-address ":3201"
    volumes:
      - minio-data:/data

  minio-init:
    image: minio/mc
    depends_on:
      minio:
        condition: service_started
    entrypoint: ["sh","-c"]
    command: |
      set -e
      until mc alias set h0 http://minio:3200 ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD} 2>/dev/null; do
        echo "Waiting for minio..."; sleep 1;
      done
      mc mb -p h0/b2-eu-cen || true

YAML
  if [[ "$INCLUDE_CADDY" == true ]]; then
  cat <<'YAML'
  caddy:
    image: caddy:latest
    depends_on:
      museum:
        condition: service_healthy
      web:
        condition: service_started
      minio:
        condition: service_started
      postgres:
        condition: service_healthy
    ports:
      - 80:80
      - 443:443
    env_file:
      - .env
    command:
      - sh
      - -c
      - |
        {
          if [ -n "${ENTE_PHOTOS_DOMAIN}" ]; then
            cat <<EOF
        ${ENTE_PHOTOS_DOMAIN} {
          reverse_proxy web:3000
        }
        EOF
          fi
          if [ -n "${ENTE_ACCOUNTS_DOMAIN}" ]; then
            cat <<EOF
        ${ENTE_ACCOUNTS_DOMAIN} {
          reverse_proxy web:3001
        }
        EOF
          fi
          if [ -n "${ENTE_ALBUMS_DOMAIN}" ]; then
            cat <<EOF
        ${ENTE_ALBUMS_DOMAIN} {
          reverse_proxy web:3002
        }
        EOF
          fi
          if [ -n "${ENTE_AUTH_DOMAIN}" ]; then
            cat <<EOF
        ${ENTE_AUTH_DOMAIN} {
          reverse_proxy web:3003
        }
        EOF
          fi
          if [ -n "${ENTE_CAST_DOMAIN}" ]; then
            cat <<EOF
        ${ENTE_CAST_DOMAIN} {
          reverse_proxy web:3004
        }
        EOF
          fi
          if [ -n "${ENTE_SHARE_DOMAIN}" ]; then
            cat <<EOF
        ${ENTE_SHARE_DOMAIN} {
          reverse_proxy web:3005
        }
        EOF
          fi
          if [ -n "${ENTE_EMBED_DOMAIN}" ]; then
            cat <<EOF
        ${ENTE_EMBED_DOMAIN} {
          reverse_proxy web:3006
        }
        EOF
          fi
          if [ -n "${ENTE_S3_DOMAIN}" ]; then
            cat <<EOF
        ${ENTE_S3_DOMAIN} {
          reverse_proxy minio:3200
        }
        EOF
          fi
          if [ -n "${ENTE_API_DOMAIN}" ]; then
            cat <<EOF
        ${ENTE_API_DOMAIN} {
          reverse_proxy museum:8080
        }
        EOF
          fi
        } > ./caddyfile
        caddy run --config ./caddyfile --adapter caddyfile
YAML
  fi
  cat <<'YAML'

volumes:
  postgres-data:
  minio-data:
YAML
  } > compose.yaml
}

start_compose() {
  # Check if ports 80 and 443 are free
  if command -v netstat >/dev/null 2>&1; then
    if netstat -tln 2>/dev/null | grep -q :80; then
      say "${YELLOW}Port 80 is in use. Please free it for Caddy.${NC}"
    fi
    if netstat -tln 2>/dev/null | grep -q :443; then
      say "${YELLOW}Port 443 is in use. Please free it for Caddy.${NC}"
    fi
  elif command -v ss >/dev/null 2>&1; then
    if ss -tln | grep -q :80; then
      say "${YELLOW}Port 80 is in use. Please free it for Caddy.${NC}"
    fi
    if ss -tln | grep -q :443; then
      say "${YELLOW}Port 443 is in use. Please free it for Caddy.${NC}"
    fi
  else
    say "${YELLOW}Unable to check port availability (netstat/ss not found). Ensure ports 80 and 443 are free.${NC}"
  fi

  local url="NOT CONFIGURED"
  if [[ -n "$ENTE_PHOTOS_DOMAIN" ]]; then
    url="https://$ENTE_PHOTOS_DOMAIN"
  fi
  say "${GREEN}Hey, it's ready to compose up!${NC}"
  say "${GREEN}Run: cd my-ente && docker compose up -d${NC}"
  say "${GREEN}Then visit:${NC} $url"

  # Remove the old compose file if it exists
  if [[ -f "../compose.yml" ]]; then
    rm "../compose.yml"
    say "${GREEN}Removed old compose.yml${NC}"
  fi
}

main() {
  TARGET_DIR="my-ente"
  if [[ -d "$TARGET_DIR" ]]; then
    say "${RED}Directory $TARGET_DIR already exists. Exiting.${NC}"
    exit 1
  fi
  mkdir -p "$TARGET_DIR"
  say "${GREEN}Created ${TARGET_DIR}${NC}"
  cd "$TARGET_DIR"

  header
  require base64 "Install base64 (coreutils) to generate credentials."
  if ! docker_compose_version_ok; then
    say "${RED}ERROR:${NC} Install Docker Compose v2.30+ (Docker Desktop ≥ 4.27)."
    exit 1
  fi

  load_env

  # Initialize domain variables
  ENTE_S3_DOMAIN=""
  ENTE_API_DOMAIN=""
  ENTE_PHOTOS_DOMAIN=""
  ENTE_ACCOUNTS_DOMAIN=""
  ENTE_ALBUMS_DOMAIN=""
  ENTE_AUTH_DOMAIN=""
  ENTE_CAST_DOMAIN=""
  ENTE_SHARE_DOMAIN=""
  ENTE_EMBED_DOMAIN=""

  say "${YELLOW}Preferences Wizard${NC}"
  say "Press Enter to accept defaults in brackets."

  # Core DB settings
  POSTGRES_USER="${POSTGRES_USER:-pguser}"
  POSTGRES_DB="${POSTGRES_DB:-ente_db}"

  # Secrets (generate if empty)
  POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-$(gen_password)}"
  MINIO_ROOT_USER="${MINIO_ROOT_USER:-minio-user-$(gen_user_suffix)}"
  MINIO_ROOT_PASSWORD="${MINIO_ROOT_PASSWORD:-$(gen_password)}"
  MUSEUM_ENCRYPTION_KEY="${MUSEUM_ENCRYPTION_KEY:-$(gen_key)}"
  MUSEUM_HASH_KEY="${MUSEUM_HASH_KEY:-$(gen_hash)}"
  MUSEUM_JWT_SECRET="${MUSEUM_JWT_SECRET:-$(gen_jwt_secret)}"

  # Admin/registration toggles
  MUSEUM_ADMIN="${MUSEUM_ADMIN:-}"
  MUSEUM_DISABLE_REGISTRATION="${MUSEUM_DISABLE_REGISTRATION:-false}"

  # Domains - S3 and API required, others optional
  ask_domain_input ENTE_S3_DOMAIN "S3"
  ask_domain_input ENTE_API_DOMAIN "API"
  ask_domain_input ENTE_PHOTOS_DOMAIN "Photos"
  ask_domain_input ENTE_ACCOUNTS_DOMAIN "Accounts"
  ask_domain_input ENTE_ALBUMS_DOMAIN "Albums"
  ask_domain_input ENTE_AUTH_DOMAIN "Auth"
  ask_domain_input ENTE_CAST_DOMAIN "Cast"
  ask_domain_input ENTE_SHARE_DOMAIN "Share/Locker"
  ask_domain_input ENTE_EMBED_DOMAIN "Embed"

  # Check required domains
  if [[ -z "$ENTE_S3_DOMAIN" ]]; then
    say "${RED}ERROR:${NC} S3 domain is required."
    exit 1
  fi
  if [[ -z "$ENTE_API_DOMAIN" ]]; then
    say "${RED}ERROR:${NC} API domain is required."
    exit 1
  fi
  if [[ -z "$ENTE_PHOTOS_DOMAIN" ]]; then
    say "${RED}ERROR:${NC} Photos domain is required."
    exit 1
  fi
  while true; do
    say "${YELLOW}Current DNS records:${NC}"
    local domains_to_check=()
    for domain_var in ENTE_S3_DOMAIN ENTE_API_DOMAIN ENTE_PHOTOS_DOMAIN ENTE_ACCOUNTS_DOMAIN ENTE_ALBUMS_DOMAIN ENTE_AUTH_DOMAIN ENTE_CAST_DOMAIN ENTE_SHARE_DOMAIN ENTE_EMBED_DOMAIN; do
      eval "domain=\$$domain_var"
      if [[ -n "$domain" ]]; then
        local ips
        ips=$(dig +short "$domain" | tr '\n' ' ' | sed 's/ $//')
        say "  $domain: ${ips:-No records}"
        domains_to_check+=("$domain_var:$domain")
      fi
    done

    if ((${#domains_to_check[@]} == 0)); then
      break
    fi

    read -r -p "Add/update DNS A records and press Enter to validate: " || true

    local failing=()
    for item in "${domains_to_check[@]}"; do
      local domain_var="${item%%:*}"
      local domain="${item#*:}"
      local ip
      ip=$(dig +short "$domain" | head -1)
      if [[ -z "$ip" ]]; then
        failing+=("$domain_var:$domain")
      fi
    done

    if ((${#failing[@]} == 0)); then
      say "${GREEN}All domains resolve successfully!${NC}"
      break
    else
      say "${RED}The following domains do not resolve:${NC}"
      for item in "${failing[@]}"; do
        local domain="${item#*:}"
        say "  $domain"
      done
      say "${YELLOW}Please re-enter them:${NC}"
      for item in "${failing[@]}"; do
        local domain_var="${item%%:*}"
        local domain="${item#*:}"
        while true; do
          read -r -p "Re-enter $domain [subdomain.domain.tld]: " val || true
          if [[ -z "$val" ]]; then
            printf -v "$domain_var" ""
            break
          fi
          if [[ "$val" =~ ^https?:// ]]; then
            say "${YELLOW}Please omit http/https.${NC}"
            continue
          fi
          local ip
          ip=$(dig +short "$val" | head -1)
          if [[ -z "$ip" ]]; then
            say "${RED}Still does not resolve. Try again.${NC}"
            continue
          fi
          say "${GREEN}Domain $val resolves to: $ip${NC}"
          printf -v "$domain_var" "$val"
          break
        done
      done
    fi
  done

  # Port exposure choices - auto-set based on enabled domains
  EXPOSE_PHOTOS=${EXPOSE_PHOTOS:-${ENTE_PHOTOS_DOMAIN:+true}}
  EXPOSE_PHOTOS=${EXPOSE_PHOTOS:-false}
  EXPOSE_ALBUMS=${EXPOSE_ALBUMS:-${ENTE_ALBUMS_DOMAIN:+true}}
  EXPOSE_ALBUMS=${EXPOSE_ALBUMS:-false}
  EXPOSE_CAST=${EXPOSE_CAST:-${ENTE_CAST_DOMAIN:+true}}
  EXPOSE_CAST=${EXPOSE_CAST:-false}
  EXPOSE_EMBED=${EXPOSE_EMBED:-${ENTE_EMBED_DOMAIN:+true}}
  EXPOSE_EMBED=${EXPOSE_EMBED:-false}
  EXPOSE_ACCOUNTS=${EXPOSE_ACCOUNTS:-${ENTE_ACCOUNTS_DOMAIN:+true}}
  EXPOSE_ACCOUNTS=${EXPOSE_ACCOUNTS:-false}
  EXPOSE_AUTH=${EXPOSE_AUTH:-${ENTE_AUTH_DOMAIN:+true}}
  EXPOSE_AUTH=${EXPOSE_AUTH:-false}
  EXPOSE_SHARE=${EXPOSE_SHARE:-${ENTE_SHARE_DOMAIN:+true}}
  EXPOSE_SHARE=${EXPOSE_SHARE:-false}

  WEB_PORT_LINES=()
  add_port() { WEB_PORT_LINES+=("      - $1"); }
  [[ "$EXPOSE_PHOTOS" == true ]] && add_port "3000:3000"
  [[ "$EXPOSE_ACCOUNTS" == true ]] && add_port "3001:3001"
  [[ "$EXPOSE_ALBUMS" == true ]] && add_port "3002:3002"
  [[ "$EXPOSE_AUTH" == true ]] && add_port "3003:3003"
  [[ "$EXPOSE_CAST" == true ]] && add_port "3004:3004"
  [[ "$EXPOSE_SHARE" == true ]] && add_port "3005:3005"
  [[ "$EXPOSE_EMBED" == true ]] && add_port "3006:3006"

  # Origins: prefer https://domain when set
  ENTE_API_ORIGIN="${ENTE_API_ORIGIN:-${ENTE_API_DOMAIN:+https://$ENTE_API_DOMAIN}}"
  ENTE_PHOTOS_ORIGIN="${ENTE_PHOTOS_ORIGIN:-${ENTE_PHOTOS_DOMAIN:+https://$ENTE_PHOTOS_DOMAIN}}"
  ENTE_ALBUMS_ORIGIN="${ENTE_ALBUMS_ORIGIN:-${ENTE_ALBUMS_DOMAIN:+https://$ENTE_ALBUMS_DOMAIN}}"
  ENTE_CAST_ORIGIN="${ENTE_CAST_ORIGIN:-${ENTE_CAST_DOMAIN:+https://$ENTE_CAST_DOMAIN}}"
  ENTE_EMBED_ORIGIN="${ENTE_EMBED_ORIGIN:-${ENTE_EMBED_DOMAIN:+https://$ENTE_EMBED_DOMAIN}}"
  ENTE_ACCOUNTS_ORIGIN="${ENTE_ACCOUNTS_ORIGIN:-${ENTE_ACCOUNTS_DOMAIN:+https://$ENTE_ACCOUNTS_DOMAIN}}"
  ENTE_AUTH_ORIGIN="${ENTE_AUTH_ORIGIN:-${ENTE_AUTH_DOMAIN:+https://$ENTE_AUTH_DOMAIN}}"
  ENTE_SHARE_ORIGIN="${ENTE_SHARE_ORIGIN:-${ENTE_SHARE_DOMAIN:+https://$ENTE_SHARE_DOMAIN}}"

  ENTE_S3_ENDPOINT="${ENTE_S3_ENDPOINT:-${ENTE_S3_DOMAIN:+https://$ENTE_S3_DOMAIN}}"
  ENTE_S3_REGION="${ENTE_S3_REGION:-eu-central-2}"
  ENTE_S3_BUCKET="${ENTE_S3_BUCKET:-b2-eu-cen}"

  say "${GREEN}[OK] Preferences captured${NC}"

  # Write .env
  for kv in \
    "POSTGRES_USER=$POSTGRES_USER" \
    "POSTGRES_DB=$POSTGRES_DB" \
    "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" \
    "MINIO_ROOT_USER=$MINIO_ROOT_USER" \
    "MINIO_ROOT_PASSWORD=$MINIO_ROOT_PASSWORD" \
    "MUSEUM_ADMIN=$MUSEUM_ADMIN" \
    "MUSEUM_DISABLE_REGISTRATION=$MUSEUM_DISABLE_REGISTRATION" \
    "MUSEUM_ENCRYPTION_KEY=$MUSEUM_ENCRYPTION_KEY" \
    "MUSEUM_HASH_KEY=$MUSEUM_HASH_KEY" \
    "MUSEUM_JWT_SECRET=$MUSEUM_JWT_SECRET" \
    "ENTE_S3_DOMAIN=${ENTE_S3_DOMAIN-}" \
    "ENTE_S3_ENDPOINT=$ENTE_S3_ENDPOINT" \
    "ENTE_S3_REGION=$ENTE_S3_REGION" \
    "ENTE_S3_BUCKET=$ENTE_S3_BUCKET" \
    "ENTE_API_DOMAIN=${ENTE_API_DOMAIN-}" \
    "ENTE_PHOTOS_DOMAIN=${ENTE_PHOTOS_DOMAIN-}" \
    "ENTE_ALBUMS_DOMAIN=${ENTE_ALBUMS_DOMAIN-}" \
    "ENTE_CAST_DOMAIN=${ENTE_CAST_DOMAIN-}" \
    "ENTE_EMBED_DOMAIN=${ENTE_EMBED_DOMAIN-}" \
    "ENTE_ACCOUNTS_DOMAIN=${ENTE_ACCOUNTS_DOMAIN-}" \
    "ENTE_AUTH_DOMAIN=${ENTE_AUTH_DOMAIN-}" \
    "ENTE_SHARE_DOMAIN=${ENTE_SHARE_DOMAIN-}" \
    "ENTE_API_ORIGIN=$ENTE_API_ORIGIN" \
    "ENTE_PHOTOS_ORIGIN=$ENTE_PHOTOS_ORIGIN" \
    "ENTE_ALBUMS_ORIGIN=$ENTE_ALBUMS_ORIGIN" \
    "ENTE_CAST_ORIGIN=$ENTE_CAST_ORIGIN" \
    "ENTE_EMBED_ORIGIN=$ENTE_EMBED_ORIGIN" \
    "ENTE_ACCOUNTS_ORIGIN=$ENTE_ACCOUNTS_ORIGIN" \
    "ENTE_AUTH_ORIGIN=$ENTE_AUTH_ORIGIN" \
    "ENTE_SHARE_ORIGIN=$ENTE_SHARE_ORIGIN"; do
    update_env "${kv%%=*}" "${kv#*=}"
  done
ask_bool() {
  local key="$1" prompt="$2" default="${3:-false}" value=""
  local current="${!key-}"
  local def="${current:-$default}"
  local prompt_suffix
  if [[ "$def" == true ]]; then
    prompt_suffix="[Y/n]"
  else
    prompt_suffix="[y/N]"
  fi
  read -r -p "$prompt $prompt_suffix: " value || true
  value=${value:-$def}
  case "$value" in
    [Yy][Ee][Ss]|[Yy]|true|TRUE) value=true ;;
    *) value=false ;;
  esac
  printf -v "$key" "%s" "$value"
}
  say "${GREEN}[OK] Wrote .env${NC}"

  ask_bool INCLUDE_CADDY "Include Caddy reverse proxy?" true

  # Generate compose.yaml
  generate_compose
  say "${GREEN}[OK] Wrote compose.yaml${NC}"

  start_compose
}

main "$@"
