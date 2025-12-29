#!/usr/bin/env bash
if [[ -z "${BASH_VERSION:-}" ]]; then
  echo "Please run with bash: bash $0 $@"
  exit 1
fi
set -euo pipefail

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'
say() { printf "%b" "$1"; }

require() {
  local cmd="$1" msg="$2"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    say "${RED}[ERR]${NC} $msg\n"
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
  say "${BLUE}[INF]${NC} Welcome to the ${BOLD}Ente setup wizard${NC}!\n"
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
  if [[ "$def" == true ]]; then yn_def="Y/n"; else yn_def="y/N"; fi
  say "${ORANGE}$prompt [$yn_def]: ${NC}"
  read -r value || true
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
  say "${ORANGE}$prompt [$def]: ${NC}"
    read -r value || true
    value="${value:-$def}"
  else
  say "${ORANGE}$prompt: ${NC}"
    read -r value || true
  fi
  printf -v "$key" "%s" "$value"
}

ask_domain_input() {
  local var_name="$1" label="$2"
  local val=""
  local current="${!var_name-}"
  if [[ -n "$current" ]]; then
    say "${ORANGE}[Q]${NC} Set $label domain [$current]: "
    read -r val || true
    val="${val:-$current}"
  else
    say "${ORANGE}[Q]${NC} Set $label domain (e.g., subdomain.example.com): "
    read -r val || true
  fi
  if [[ -n "$val" ]] && [[ ! "$val" =~ ^https?:// ]]; then
    while true; do
      local ip
      ip=$(dig +short "$val" | head -1)
      if [[ -z "$ip" ]]; then
        say "${RED}Domain $val does not resolve. Please re-enter or leave empty.${NC}\n"
        say "${ORANGE}Re-enter $label domain [subdomain.domain.tld]: ${NC}"
        read -r val || true
        if [[ -z "$val" ]]; then
          printf -v "$var_name" ""
          break
        fi
      else
        printf -v "$var_name" "$val"
        break
      fi
    done
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
    env_file:
      - .env
    environment:
YAML
    cat <<YAML
      ENTE_APPS_ACCOUNTS: ${ENTE_APPS_ACCOUNTS:-$ENTE_ACCOUNTS_ORIGIN}
      ENTE_APPS_CAST: ${ENTE_APPS_CAST:-$ENTE_CAST_ORIGIN}
      ENTE_APPS_EMBED_ALBUMS: ${ENTE_APPS_EMBED_ALBUMS:-$ENTE_EMBED_ORIGIN}
      ENTE_APPS_PUBLIC_ALBUMS: ${ENTE_APPS_PUBLIC_ALBUMS:-$ENTE_ALBUMS_ORIGIN}
      ENTE_APPS_PUBLIC_LOCKER: ${ENTE_APPS_PUBLIC_LOCKER:-$ENTE_SHARE_ORIGIN}
YAML
    cat <<'YAML'
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
      for port_line in "${WEB_PORT_LINES[@]}"; do
        if [[ $port_line == \#* ]]; then
          echo "      $port_line"
        else
          echo "      - $port_line"
        fi
      done
    fi
    cat <<'YAML'
    env_file:
      - .env
  postgres:
    image: postgres:15
    env_file:
      - .env
    environment:
      POSTGRES_DB: ${ENTE_DB_NAME}
      POSTGRES_USER: ${ENTE_DB_USER}
      POSTGRES_PASSWORD: ${ENTE_DB_PASSWORD}
    healthcheck:
      test: pg_isready -q -d ${ENTE_DB_NAME} -U ${ENTE_DB_USER}
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
    environment:
      MINIO_ROOT_USER: ${ENTE_S3_B2_EU_CEN_KEY}
      MINIO_ROOT_PASSWORD: ${ENTE_S3_B2_EU_CEN_SECRET}
    command: server /data --address ":3200" --console-address ":3201"
    volumes:
      - minio-data:/data
    post_start:
      - command: |
          sh -c '
          #!/bin/sh

          while ! mc alias set h0 http://minio:3200 ${ENTE_S3_B2_EU_CEN_KEY} ${ENTE_S3_B2_EU_CEN_SECRET} 2>/dev/null
          do
            echo "Waiting for minio..."
            sleep 0.5
          done

          cd /data

          mc mb -p ${ENTE_S3_B2_EU_CEN_BUCKET}
          '
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
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - ./logs:/var/log/caddy
      - caddy_data:/data
      - caddy_config:/config
    command: ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
volumes:
  postgres-data:
  minio-data:
  caddy_data:
  caddy_config:

YAML
  } > compose.yaml
}

generate_caddyfile() {
  cat <<-EOF
$CADDY_PHOTOS_DOMAIN {
	log {
		output file /var/log/caddy/$CADDY_PHOTOS_DOMAIN.access.log {
			roll_size 10mb
			roll_keep 0
		}
		format json
	}

	handle_path /api/* {
		reverse_proxy museum:8080
	}

	handle {
		reverse_proxy web:3000
	}
}
EOF
  echo ""

  if [[ -n "$CADDY_ACCOUNTS_DOMAIN" ]]; then
    cat <<-EOF
$CADDY_ACCOUNTS_DOMAIN {
	log {
		output file /var/log/caddy/$CADDY_ACCOUNTS_DOMAIN.access.log {
			roll_size 10mb
			roll_keep 0
		}
		format json
	}

	reverse_proxy web:3001
}
EOF
    echo ""
  fi
  if [[ -n "$CADDY_ALBUMS_DOMAIN" ]]; then
    cat <<-EOF
$CADDY_ALBUMS_DOMAIN {
	log {
		output file /var/log/caddy/$CADDY_ALBUMS_DOMAIN.access.log {
			roll_size 10mb
			roll_keep 0
		}
		format json
	}

	reverse_proxy web:3002
}
EOF
    echo ""
  fi
  if [[ -n "$CADDY_AUTH_DOMAIN" ]]; then
    cat <<-EOF
$CADDY_AUTH_DOMAIN {
	log {
		output file /var/log/caddy/$CADDY_AUTH_DOMAIN.access.log {
			roll_size 10mb
			roll_keep 0
		}
		format json
	}

	reverse_proxy web:3003
}
EOF
    echo ""
  fi
  if [[ -n "$CADDY_CAST_DOMAIN" ]]; then
    cat <<-EOF
$CADDY_CAST_DOMAIN {
	log {
		output file /var/log/caddy/$CADDY_CAST_DOMAIN.access.log {
			roll_size 10mb
			roll_keep 0
		}
		format json
	}

	reverse_proxy web:3004
}
EOF
    echo ""
  fi
  if [[ -n "$CADDY_SHARE_DOMAIN" ]]; then
    cat <<-EOF
$CADDY_SHARE_DOMAIN {
	log {
		output file /var/log/caddy/$CADDY_SHARE_DOMAIN.access.log {
			roll_size 10mb
			roll_keep 0
		}
		format json
	}

	reverse_proxy web:3005
}
EOF
    echo ""
  fi
  if [[ -n "$CADDY_EMBED_DOMAIN" ]]; then
    cat <<-EOF
$CADDY_EMBED_DOMAIN {
	log {
		output file /var/log/caddy/$CADDY_EMBED_DOMAIN.access.log {
			roll_size 10mb
			roll_keep 0
		}
		format json
	}

	reverse_proxy web:3006
}
EOF
    echo ""
  fi
  cat <<-EOF
$CADDY_S3_DOMAIN {
	log {
		output file /var/log/caddy/$CADDY_S3_DOMAIN.access.log {
			roll_size 10mb
			roll_keep 0
		}
		format json
	}

	reverse_proxy minio:3200
}
EOF
}

start_compose() {
  local is_existing_setup="${1:-false}"
  say "\n"
  # Check if Ente containers or volumes exist
  local cleanup_mode="none"
  if [[ "$is_existing_setup" == true ]]; then
    # For existing setups, don't ask about volume cleanup - just clean containers
    cleanup_mode="containers"
    VOLUMES_REMOVED=false
  elif docker compose ps -q | grep -q . || docker volume ls | grep -q my-ente; then
    say "\n${YELLOW}[WRN]${NC} Delete existing Ente Data? (Say Y for clean-install) [y/N]: "
    read -r cleanup_input || true
    cleanup_input=${cleanup_input:-n}
    case "$cleanup_input" in
      [Yy][Ee][Ss]|[Yy]|true|TRUE) 
        cleanup_mode="volumes"
        VOLUMES_REMOVED=true
        ;;
      *) 
        cleanup_mode="containers"
        VOLUMES_REMOVED=false
        ;;
    esac
  else
    cleanup_mode="containers"
    VOLUMES_REMOVED=true
  fi
  # Check if ports 80 and 443 are free
  if command -v netstat >/dev/null 2>&1; then
    if netstat -tln 2>/dev/null | grep -q :80; then
      say "${YELLOW}Port 80 is in use. Please free it for Caddy.${NC}\n"
    fi
    if netstat -tln 2>/dev/null | grep -q :443; then
      say "${YELLOW}Port 443 is in use. Please free it for Caddy.${NC}\n"
    fi
  elif command -v ss >/dev/null 2>&1; then
    if ss -tln | grep -q :80; then
      say "${YELLOW}Port 80 is in use. Please free it for Caddy.${NC}\n"
    fi
    if ss -tln | grep -q :443; then
      say "${YELLOW}Port 443 is in use. Please free it for Caddy.${NC}\n"
    fi
  else
    say "${YELLOW}Unable to check port availability (netstat/ss not found). Ensure ports 80 and 443 are free.${NC}\n"
  fi

  local url="https://$CADDY_PHOTOS_DOMAIN"

  say "\n${ORANGE}[Q]${NC} Do you want to start Ente? [Y/n]: "
  read -r start_input || true
  start_input=${start_input:-y}
  case "$start_input" in
    [Yy][Ee][Ss]|[Yy]|true|TRUE|"") START=true ;;
    *) START=false ;;
  esac

  if [[ "$START" == true ]]; then
    say "${BLUE}[INF]${NC} Starting Ente...\n"
    # Perform cleanup based on user choice
    case "$cleanup_mode" in
      "volumes")
        docker compose down -v --remove-orphans
        ;;
      "containers")
        docker compose down --remove-orphans
        ;;
    esac
    docker compose up -d
    if [[ "$VOLUMES_REMOVED" == true ]]; then
      # Show visit instructions
      say "\n${BLUE}[INF]${NC} Hey, visit: ${BOLD}$url/credentials${NC} and sign up\n"
      say "\n${ORANGE}[Q]${NC} Fetch verification code? [Y/n]: "
      read -r fetch_input || true
      fetch_input=${fetch_input:-y}
      case "$fetch_input" in
        [Yy][Ee][Ss]|[Yy]|true|TRUE|"") FETCH=true ;;
        *) FETCH=false ;;
      esac
      if [[ "$FETCH" == true ]]; then
        docker compose --env-file .env logs museum 2>&1 | grep "Verification code:" || say "${BLUE}[INF]${NC} Verification code not found yet. Did you sign up yet?\n"
      fi
    fi
  fi

  if [[ "$START" == false ]]; then
    say "\nTo start the cluster manually:\n"
    say " $ cd my-ente\n"
    say " $ docker compose --env-file .env up -d\n"
    say "\n"
  fi
  say "${GREEN}[OK]${NC} Ente setup complete!\n"
}

main() {
  header
  TARGET_DIR="my-ente"
  local config_msg=""
  local is_existing_setup=false
  if [[ -d "$TARGET_DIR" ]]; then
    config_msg="Directory $TARGET_DIR exists, loading existing configuration"
    is_existing_setup=true
    cd "$TARGET_DIR"
    load_env
  else
    mkdir -p "$TARGET_DIR"
    cd "$TARGET_DIR"
  fi

  [[ -n "$config_msg" ]] && say "${BLUE}[INF]${NC} $config_msg\n"
  require base64 "Install base64 (coreutils) to generate credentials."
  if ! docker_compose_version_ok; then
    say "${RED}[ERR]${NC} Install Docker Compose v2.30+ (Docker Desktop ≥ 4.27).\n"
    exit 1
  fi
  load_env

  # Initialize domain variables (only if not already loaded)
  CADDY_S3_DOMAIN="${CADDY_S3_DOMAIN:-}"
  CADDY_API_DOMAIN="${CADDY_API_DOMAIN:-}"
  CADDY_PHOTOS_DOMAIN="${CADDY_PHOTOS_DOMAIN:-}"
  CADDY_ACCOUNTS_DOMAIN="${CADDY_ACCOUNTS_DOMAIN:-}"
  CADDY_ALBUMS_DOMAIN="${CADDY_ALBUMS_DOMAIN:-}"
  CADDY_AUTH_DOMAIN="${CADDY_AUTH_DOMAIN:-}"
  CADDY_CAST_DOMAIN="${CADDY_CAST_DOMAIN:-}"
  CADDY_SHARE_DOMAIN="${CADDY_SHARE_DOMAIN:-}"
  CADDY_EMBED_DOMAIN="${CADDY_EMBED_DOMAIN:-}"
  say "${BLUE}[INF]${NC} Hit ${GREEN}[ENTER]${NC} to skip / enter new values.\n"
  say "\n"

  # Core DB settings
  ENTE_DB_USER="${PG:-pguser}"
  ENTE_DB_NAME="${ENTE_DB_NAME:-ente_db}"

  # Secrets (generate if empty)
  ENTE_DB_PASSWORD="${ENTE_DB_PASSWORD:-$(gen_password)}"
  ENTE_S3_B2_EU_CEN_KEY="${ENTE_S3_B2_EU_CEN_KEY:-minio-user-$(gen_user_suffix)}"
  ENTE_S3_B2_EU_CEN_SECRET="${ENTE_S3_B2_EU_CEN_SECRET:-$(gen_password)}"
  ENTE_KEY_ENCRYPTION="${ENTE_KEY_ENCRYPTION:-$(gen_key)}"
  ENTE_KEY_HASH="${ENTE_KEY_HASH:-$(gen_hash)}"
  ENTE_JWT_SECRET="${ENTE_JWT_SECRET:-$(gen_jwt_secret)}"

  # Domains - S3 and Photos required, others optional
  while true; do
    ask_domain_input CADDY_S3_DOMAIN "S3"
    ask_domain_input CADDY_PHOTOS_DOMAIN "Photos"
    ask_domain_input CADDY_ACCOUNTS_DOMAIN "Accounts"
    ask_domain_input CADDY_ALBUMS_DOMAIN "Albums"
    ask_domain_input CADDY_AUTH_DOMAIN "Auth"
    ask_domain_input CADDY_CAST_DOMAIN "Cast"
    ask_domain_input CADDY_SHARE_DOMAIN "Share/Locker"
    ask_domain_input CADDY_EMBED_DOMAIN "Embed"

    if [[ -z "$CADDY_S3_DOMAIN" ]]; then
      say "\n${RED}[ERR]${NC} S3 domain is required. Restarting domain configuration...\n\n"
      continue
    fi
    if [[ -z "$CADDY_PHOTOS_DOMAIN" ]]; then
      say "\n${RED}[ERR]${NC} Photos domain is required. Restarting domain configuration...\n\n"
      continue
    fi

    # Set API domain to Photos domain for unified routing
    CADDY_API_DOMAIN="$CADDY_PHOTOS_DOMAIN"
    if [[ -z "$CADDY_PHOTOS_DOMAIN" ]]; then
      say "\n${RED}[ERR]${NC} Photos domain is required. Restarting domain configuration...\n\n"
      continue
    fi

    # Show DNS records and ask for confirmation
    say "\n${BLUE}[INF]${NC} DNS A records for configured domains:\n"
    for domain_var in CADDY_S3_DOMAIN CADDY_PHOTOS_DOMAIN CADDY_ACCOUNTS_DOMAIN CADDY_ALBUMS_DOMAIN CADDY_AUTH_DOMAIN CADDY_CAST_DOMAIN CADDY_SHARE_DOMAIN CADDY_EMBED_DOMAIN; do
      eval "domain=\$$domain_var"
      if [[ -n "$domain" ]]; then
        local ips
        ips=$(dig +short "$domain" | tr '\n' ' ' | sed 's/ $//')
        say "  $domain: ${ips:-No records}\n"
      fi
    done

    say "\n${ORANGE}[Q]${NC} Continue with these DNS records? (Y/n): "
    read -r confirm || true
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
      say "${YELLOW}Restarting domain configuration...${NC}\n\n"
      continue
    else
      break
    fi
  done

  # Origins
  ENTE_API_ORIGIN="${CADDY_API_DOMAIN:+https://$CADDY_API_DOMAIN/api}"
  ENTE_PHOTOS_ORIGIN="${CADDY_PHOTOS_DOMAIN:+https://$CADDY_PHOTOS_DOMAIN}"
  ENTE_ALBUMS_ORIGIN="${CADDY_ALBUMS_DOMAIN:+https://$CADDY_ALBUMS_DOMAIN}"
  ENTE_CAST_ORIGIN="${CADDY_CAST_DOMAIN:+https://$CADDY_CAST_DOMAIN}"
  ENTE_EMBED_ORIGIN="${CADDY_EMBED_DOMAIN:+https://$CADDY_EMBED_DOMAIN}"
  ENTE_ACCOUNTS_ORIGIN="${CADDY_ACCOUNTS_DOMAIN:+https://$CADDY_ACCOUNTS_DOMAIN}"
  ENTE_AUTH_ORIGIN="${CADDY_AUTH_DOMAIN:+https://$CADDY_AUTH_DOMAIN}"
  ENTE_SHARE_ORIGIN="${CADDY_SHARE_DOMAIN:+https://$CADDY_SHARE_DOMAIN}"

  # Set all ENTE_ environment variables
  ENTE_DB_HOST="${ENTE_DB_HOST:-postgres}"
  ENTE_DB_PORT="${ENTE_DB_PORT:-5432}"
  ENTE_DB_USER="${ENTE_DB_USER:-pguser}"

  ENTE_INTERNAL_ADMIN="${ENTE_INTERNAL_ADMIN:-}"
  ENTE_INTERNAL_DISABLE_REGISTRATION="${ENTE_INTERNAL_DISABLE_REGISTRATION:-false}"
  
  ENTE_S3_ARE_LOCAL_BUCKETS="${ENTE_S3_ARE_LOCAL_BUCKETS:-true}"
  ENTE_S3_USE_PATH_STYLE_URLS="${ENTE_S3_USE_PATH_STYLE_URLS:-false}"

  ENTE_S3_B2_EU_CEN_ENDPOINT="${CADDY_S3_DOMAIN:+https://$CADDY_S3_DOMAIN}"
  ENTE_S3_B2_EU_CEN_BUCKET=b2-eu-cen
  ENTE_S3_B2_EU_CEN_REGION=eu-central-2

  # Expose web ports based on configured domains
  WEB_PORT_LINES=()
  add_port() { WEB_PORT_LINES+=("$1 # $2"); }
  add_commented_port() { WEB_PORT_LINES+=("# $1 # $2"); }
  [[ -n "$CADDY_PHOTOS_DOMAIN" ]] && add_port "3000:3000" "Photos Web" || add_commented_port "3000:3000" "Photos Web"
  [[ -n "$CADDY_ACCOUNTS_DOMAIN" ]] && add_port "3001:3001" "Accounts" || add_commented_port "3001:3001" "Accounts"
  [[ -n "$CADDY_ALBUMS_DOMAIN" ]] && add_port "3002:3002" "Public albums" || add_commented_port "3002:3002" "Public albums"
  [[ -n "$CADDY_AUTH_DOMAIN" ]] && add_port "3003:3003" "Auth" || add_commented_port "3003:3003" "Auth"
  [[ -n "$CADDY_CAST_DOMAIN" ]] && add_port "3004:3004" "Cast" || add_commented_port "3004:3004" "Cast"
  [[ -n "$CADDY_SHARE_DOMAIN" ]] && add_port "3005:3005" "Share" || add_commented_port "3005:3005" "Share"
  [[ -n "$CADDY_EMBED_DOMAIN" ]] && add_port "3006:3006" "Embed" || add_commented_port "3006:3006" "Embed"

  # Write .env
  kv=(
    "CADDY_S3_DOMAIN=$CADDY_S3_DOMAIN"
    "CADDY_API_DOMAIN=$CADDY_API_DOMAIN"
    "CADDY_PHOTOS_DOMAIN=$CADDY_PHOTOS_DOMAIN"
    "CADDY_ACCOUNTS_DOMAIN=$CADDY_ACCOUNTS_DOMAIN"
    "CADDY_ALBUMS_DOMAIN=$CADDY_ALBUMS_DOMAIN"
    "CADDY_AUTH_DOMAIN=$CADDY_AUTH_DOMAIN"
    "CADDY_CAST_DOMAIN=$CADDY_CAST_DOMAIN"
    "CADDY_SHARE_DOMAIN=$CADDY_SHARE_DOMAIN"
    "CADDY_EMBED_DOMAIN=$CADDY_EMBED_DOMAIN"
    "ENTE_DB_HOST=$ENTE_DB_HOST"
    "ENTE_DB_PORT=$ENTE_DB_PORT"
    "ENTE_DB_NAME=$ENTE_DB_NAME"
    "ENTE_DB_USER=$ENTE_DB_USER"
    "ENTE_DB_PASSWORD=$ENTE_DB_PASSWORD"
    "ENTE_S3_ARE_LOCAL_BUCKETS=$ENTE_S3_ARE_LOCAL_BUCKETS"
    "ENTE_S3_USE_PATH_STYLE_URLS=$ENTE_S3_USE_PATH_STYLE_URLS"
    "ENTE_S3_B2_EU_CEN_KEY=$ENTE_S3_B2_EU_CEN_KEY"
    "ENTE_S3_B2_EU_CEN_SECRET=$ENTE_S3_B2_EU_CEN_SECRET"
    "ENTE_S3_B2_EU_CEN_ENDPOINT=$ENTE_S3_B2_EU_CEN_ENDPOINT"
    "ENTE_S3_B2_EU_CEN_REGION=$ENTE_S3_B2_EU_CEN_REGION"
    "ENTE_S3_B2_EU_CEN_BUCKET=$ENTE_S3_B2_EU_CEN_BUCKET"
    "ENTE_KEY_ENCRYPTION=$ENTE_KEY_ENCRYPTION"
    "ENTE_KEY_HASH=$ENTE_KEY_HASH"
    "ENTE_JWT_SECRET=$ENTE_JWT_SECRET"
    "ENTE_INTERNAL_ADMIN=$ENTE_INTERNAL_ADMIN"
    "ENTE_INTERNAL_DISABLE_REGISTRATION=$ENTE_INTERNAL_DISABLE_REGISTRATION"
    "ENTE_ACCOUNTS_ORIGIN=$ENTE_ACCOUNTS_ORIGIN"
    "ENTE_ALBUMS_ORIGIN=$ENTE_ALBUMS_ORIGIN"
    "ENTE_API_ORIGIN=$ENTE_API_ORIGIN"
    "ENTE_AUTH_ORIGIN=$ENTE_AUTH_ORIGIN"
    "ENTE_CAST_ORIGIN=$ENTE_CAST_ORIGIN"
    "ENTE_EMBED_ORIGIN=$ENTE_EMBED_ORIGIN"
    "ENTE_PHOTOS_ORIGIN=$ENTE_PHOTOS_ORIGIN"
    "ENTE_SHARE_ORIGIN=$ENTE_SHARE_ORIGIN"
  )

  for item in "${kv[@]}"; do
    if [[ "$item" =~ ^# ]]; then
      if ! grep -q "^$item$" .env 2>/dev/null; then
        echo "$item" >> .env
      fi
    else
      update_env "${item%%=*}" "${item#*=}"
    fi
  done


  generate_compose
  generate_caddyfile > Caddyfile
  say "${GREEN}[OK]${NC} Written to compose.yaml and Caddyfile"
  start_compose "$is_existing_setup"
}

main "$@"
