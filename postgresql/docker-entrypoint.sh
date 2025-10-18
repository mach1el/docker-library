#!/usr/bin/env sh
# shellcheck shell=sh
set -eu
# Enable pipefail when available (ash supports it; dash may not)
if ( set -o pipefail ) 2>/dev/null; then set -o pipefail; fi

# -------------------------------
# Defaults & toggles
# -------------------------------
: "${POSTGRES_USER:=postgres}"
: "${POSTGRES_DB:=${POSTGRES_USER}}"
: "${POSTGRES_INIT_SCRIPTS_DIR:=/docker-entrypoint-initdb.d}"
: "${POSTGRES_LOG_STATEMENT:=all}"
: "${POSTGRES_PORT:=5432}"
: "${PGDATA:=/var/lib/postgresql/data}"

# External connectivity toggle:
# - Set POSTGRES_ALLOW_EXTERNAL=1 to listen on all interfaces and open pg_hba to the CIDRs in PG_ALLOWED_CIDRS
# - Leave unset/0 to restrict to localhost only.
: "${POSTGRES_ALLOW_EXTERNAL:=0}"
: "${PG_ALLOWED_CIDRS:=0.0.0.0/0,::/0}"

# -------------------------------
# Password policy (required)
# -------------------------------
if [ -z "${POSTGRES_PASSWORD:-}" ]; then
  echo "ERROR: POSTGRES_PASSWORD is required (passwords must be set for all roles)." >&2
  exit 1
fi
: "${POSTGRES_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD}}"

# Authentication method is password-based (md5). We set passwords for roles below.
authMethod="md5"

# -------------------------------
# Helpers
# -------------------------------
sql_escape() {
  # Escape single quotes for SQL string literal
  # Usage: sql_escape "O'Hara" -> O''Hara
  # shellcheck disable=SC2001
  echo "${1:-}" | sed "s/'/''/g"
}

PW_ESC="$(sql_escape "${POSTGRES_PASSWORD}")"
PW_PG_ESC="$(sql_escape "${POSTGRES_POSTGRES_PASSWORD}")"

# Ensure PGDATA exists and owned by postgres
mkdir -p "$PGDATA"
chown -R postgres:postgres "$PGDATA"
chmod 700 "$PGDATA"

init_db() {
  echo "Initializing database in $PGDATA ..."

  if [ -n "${POSTGRES_INITDB_ARGS:-}" ]; then
    gosu postgres initdb ${POSTGRES_INITDB_ARGS}
  else
    gosu postgres initdb
  fi

  # Start a temporary server to run init scripts (bind only to localhost, custom port)
  gosu postgres pg_ctl -D "$PGDATA" -o "-c listen_addresses=localhost -c port=${POSTGRES_PORT}" -w start

  # --- Ensure 'postgres' superuser has a password ---
  gosu postgres psql --set ON_ERROR_STOP=1 --username postgres --no-password <<EOSQL
ALTER ROLE "postgres" WITH LOGIN PASSWORD '${PW_PG_ESC}';
EOSQL

  # --- Ensure application role exists, has LOGIN, and password set (works for postgres or custom name) ---
  gosu postgres psql --set ON_ERROR_STOP=1 --username postgres --no-password <<EOSQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '$POSTGRES_USER') THEN
    CREATE ROLE "$POSTGRES_USER" LOGIN;
  ELSE
    ALTER ROLE "$POSTGRES_USER" WITH LOGIN;
  END IF;
END
\$\$;
ALTER ROLE "$POSTGRES_USER" WITH PASSWORD '${PW_ESC}';
EOSQL

  # --- Ensure database exists and is owned by POSTGRES_USER ---
  gosu postgres psql --set ON_ERROR_STOP=1 --username postgres --no-password <<EOSQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = '$POSTGRES_DB') THEN
    CREATE DATABASE "$POSTGRES_DB" OWNER "$POSTGRES_USER";
  ELSE
    ALTER DATABASE "$POSTGRES_DB" OWNER TO "$POSTGRES_USER";
  END IF;
END
\$\$;
EOSQL

  # Run user-provided initialization scripts (top-level only, sorted)
  if [ -d "$POSTGRES_INIT_SCRIPTS_DIR" ]; then
    echo "Running init scripts in $POSTGRES_INIT_SCRIPTS_DIR ..."
    # Only top-level files, sorted
    for f in $(find "$POSTGRES_INIT_SCRIPTS_DIR" -maxdepth 1 -type f | sort); do
      case "$f" in
        *.sh)
          echo "Running shell script: $f"
          # shellcheck disable=SC1090
          . "$f"
          ;;
        *.sql)
          echo "Running SQL file: $f"
          gosu postgres psql --set ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" < "$f"
          ;;
        *.sql.gz)
          echo "Running SQL gzip file: $f"
          gunzip -c "$f" | gosu postgres psql --set ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB"
          ;;
        *)
          echo "Ignoring (unknown extension): $f"
          ;;
      esac
    done
  fi

  # Stop temporary server
  gosu postgres pg_ctl -D "$PGDATA" -m fast -w stop
}

configure_listen_and_hba() {
  # Set listen_addresses based on external toggle (idempotent edit of postgresql.conf)
  desired_listen="localhost"
  if [ "$POSTGRES_ALLOW_EXTERNAL" = "1" ]; then
    desired_listen="*"
  fi

  conf="$PGDATA/postgresql.conf"
  touch "$conf"

  # Ensure port and listen_addresses are set (replace or append)
  if grep -q "^[#[:space:]]*listen_addresses[[:space:]]*=" "$conf"; then
    sed -i "s|^[#[:space:]]*listen_addresses[[:space:]]*=.*|listen_addresses = '${desired_listen}'|g" "$conf"
  else
    printf "\nlisten_addresses = '%s'\n" "$desired_listen" >> "$conf"
  fi

  if grep -q "^[#[:space:]]*port[[:space:]]*=" "$conf"; then
    sed -i "s|^[#[:space:]]*port[[:space:]]*=.*|port = ${POSTGRES_PORT}|g" "$conf"
  else
    printf "port = %s\n" "$POSTGRES_PORT" >> "$conf"
  fi

  # Configure pg_hba.conf rules idempotently
  hba="$PGDATA/pg_hba.conf"
  touch "$hba"
  # Remove prior managed entries to avoid duplicates
  sed -i '/# managed-by-entrypoint$/d' "$hba"

  if [ "$POSTGRES_ALLOW_EXTERNAL" = "1" ]; then
    # Normalize commas/spaces to one-per-line and iterate
    printf "%s" "$PG_ALLOWED_CIDRS" | tr ',' ' ' | tr -s ' ' '\n' | while IFS= read -r cidr; do
      [ -n "$cidr" ] || continue
      line="host all all ${cidr} ${authMethod} # managed-by-entrypoint"
      grep -qxF "$line" "$hba" || echo "$line" >> "$hba"
    done
  else
    # Localhost only (both IPv4 and IPv6)
    for cidr in 127.0.0.1/32 ::1/128; do
      line="host all all ${cidr} ${authMethod} # managed-by-entrypoint"
      grep -qxF "$line" "$hba" || echo "$line" >> "$hba"
    done
  fi
}

print_listen_summary() {
  listen="unknown"
  port="$POSTGRES_PORT"
  if grep -q "^[#[:space:]]*listen_addresses[[:space:]]*=" "$PGDATA/postgresql.conf"; then
    listen=$(awk -F"'" '/^[#[:space:]]*listen_addresses[[:space:]]*=/ {print $2}' "$PGDATA/postgresql.conf")
  fi
  if grep -q "^[#[:space:]]*port[[:space:]]*=" "$PGDATA/postgresql.conf"; then
    port=$(awk -F"=" '/^[#[:space:]]*port[[:space:]]*=/ {gsub(/[[:space:]]/,"",$2); print $2}' "$PGDATA/postgresql.conf")
  fi
  echo "Starting postgres... (listen_addresses=${listen}, port=${port})"
}

main() {
  # Initialize once
  if [ -z "$(ls -A "$PGDATA" 2>/dev/null || true)" ]; then
    init_db
  fi

  configure_listen_and_hba
  print_listen_summary

  # Exec postgres as postgres user, preserving any passed args (e.g., -c settings)
  # Always enforce log_statement and port unless overridden by explicit args.
  exec gosu postgres "$@" -c "port=${POSTGRES_PORT}" -c "log_statement=${POSTGRES_LOG_STATEMENT}"
}

main "$@"