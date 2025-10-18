# PostgreSQL Docker Image

![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Postgres](https://img.shields.io/badge/postgres-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white)
![imgsize](https://img.shields.io/docker/image-size/mich43l/postgresql/latest?color=orange)
![dockerautomated](https://img.shields.io/docker/automated/mich43l/postgresql)

This repository contains the Dockerfile and resources to build a lightweight and efficient PostgreSQL container based on the latest Debian image. The container is designed to run PostgreSQL securely and flexibly, providing a robust foundation for database-driven applications.

This image/entrypoint provides a secure, Postgres-first startup with:
- A strict localhost-by-default network posture
- An explicit external-access toggle with CIDR allowlisting
- Guaranteed password setup for **both** `postgres` and your `POSTGRES_USER`
- Idempotent config updates for `postgresql.conf` and `pg_hba.conf`
- Standard init script support (`*.sh`, `*.sql`, `*.sql.gz`)

## Features

- **PostgreSQL Version**: Configurable via build argument (`PGSQL_VERSION`), defaults to `17`.
- **Lightweight Base**: Built on the latest Debian base image for stability and security.
- **Locale Support**: Supports configurable locale settings (`LANG`, `CC`, and `ENCODING`).
- **Custom Entrypoint**: Includes a customizable `docker-entrypoint.sh` script for initialization.
- **Enhanced Security**: Utilizes `gosu` to manage privilege escalation.
- **Persistent Data**: Data volume mounted at `/var/lib/postgresql/data` for data persistence.
- **Dynamic Configuration**: Configured to accept external connections by default (`listen_addresses = '*'`).
- **Custom Initialization**: Supports initialization scripts via `/docker-entrypoint-initdb.d`.
- **Local-only by default**  `listen_addresses='localhost'`, `pg_hba` only allows `127.0.0.1/32` and `::1/128`.
- **External access (opt-in)** 
  - Set `POSTGRES_ALLOW_EXTERNAL=1` and provide `PG_ALLOWED_CIDRS` (comma or space separated). 
  - Example: `PG_ALLOWED_CIDRS="192.168.0.0/16 10.0.0.0/8 ::1/128"`
- **Always set passwords**  
  On first init, sets passwords for:
  - `postgres` (from `POSTGRES_POSTGRES_PASSWORD` or falls back to `POSTGRES_PASSWORD`)
  - `POSTGRES_USER` (defaults to `postgres`)
- **Idempotent config**  
  On every start, the entrypoint updates `postgresql.conf` (`listen_addresses`, `port`) and rewrites managed `pg_hba.conf` lines.

## Volumes

* `/var/lib/postgresql/data`: Directory to store database files.

## Initialization Scripts

Place any `.sql` or `.sh` files into `/docker-entrypoint-initdb.d` to run during container initialization.

## Security

This image incorporates best practices for security:

* Runs PostgreSQL as a non-root user `(postgres)`.
* Leverages gosu for privilege escalation.
* Prepares directories with strict permissions.

## Build image

```bash
git clone https://github.com/mach1el/docker-library.git && \
  cd docker-library/postgresql && \
  docker buildx build --platform linux/amd64 build -t postgresql .
```


```bash
docker build --build-arg PGSQL_VERSION=17 -t mich43l/postgresql .
```
> `Build with arguments`

## Variables

### Build argument
 
| Variables     | Default       | Description                                                  |
|:--------------|:--------------|:-------------------------------------------------------------|
| PGSQL_VERSION | `17`          | Default postgresql version.                                  |
| CC            | `en_US`       | Specifies the input source file for locale definitions.      |
| LANG          | `en_US.UTF-8` | Specifies the name of the locale to generate.                |
| ENCODING      | `UTF-8`       | Specifies the character encoding file to use for the locale. |
 
### Run environment
 
## Environment Variables

 Variable | Default | When applied | Description |
|---|---|---|---|
| `POSTGRES_USER` | `postgres` | **Init only** | Role ensured to exist with `LOGIN`; password set at init. |
| `POSTGRES_DB` | `POSTGRES_USER` | **Init only** | Database ensured to exist; ownership set to `POSTGRES_USER`. |
| `POSTGRES_PASSWORD` | **(required)** | **Init only** | Password for `POSTGRES_USER`. |
| `POSTGRES_POSTGRES_PASSWORD` | `POSTGRES_PASSWORD` | **Init only** | Password for `postgres` superuser. |
| `POSTGRES_ALLOW_EXTERNAL` | `0` | **Every start** | `0` → localhost only; `1` → all interfaces. |
| `PG_ALLOWED_CIDRS` | `0.0.0.0/0,::/0` | **Every start** | CIDRs allowed in `pg_hba.conf` when external is enabled. |
| `POSTGRES_PORT` | `5432` | **Every start** | Postgres port (also written to `postgresql.conf`). |
| `POSTGRES_LOG_STATEMENT` | `all` | **Every start** | Applied as `-c log_statement=...`. |
| `POSTGRES_INIT_SCRIPTS_DIR` | `/docker-entrypoint-initdb.d` | **Init only** | Run `*.sh`, `*.sql`, `*.sql.gz` once at init. |
| `PGDATA` | `/var/lib/postgresql/data` | Always | Data directory. |
| `POSTGRES_INITDB_ARGS` | *(empty)* | **Init only** | Extra raw args for `initdb` (merged with the envs below). |
| `LANG`, `LC_ALL` | *(image default)* | Runtime | Container locale (e.g., `C.UTF-8`). |
| `PGCLIENTENCODING` | *(unset)* | Runtime | Client encoding for `psql`/libpq. |

> **Init vs Restart**: After first initialization, changing user/db/password/locale/encoding **won’t** auto-apply. See “Changing settings later”.

## Quickstart

### A) Local-only (default)
```bash
docker run -d --name pg \
  -e POSTGRES_PASSWORD='secret' \
  -v pgdata:/var/lib/postgresql/data \
  -v "$PWD/docker-entrypoint.sh:/usr/local/bin/docker-entrypoint.sh:ro" \
  mich43l/postgresql
```

### B) External access (host 2345 → container 5432), allow localhost + bridge + LAN
```bash
docker run -d --name pg \
  -e POSTGRES_PASSWORD='secret' \
  -e POSTGRES_ALLOW_EXTERNAL=1 \
  -e PG_ALLOWED_CIDRS="127.0.0.1/32,::1/128,172.17.0.0/16,192.168.0.0/16" \
  -e POSTGRES_PORT=5432 \
  -v pgdata:/var/lib/postgresql/data \
  -v "$PWD/docker-entrypoint.sh:/usr/local/bin/docker-entrypoint.sh:ro" \
  -p 2345:5432 \
  mich43l/postgresql

PGPASSWORD=secret psql -h 127.0.0.1 -p 2345 -U postgres -d postgres
```

## Docker compose
```yml
services:
  pg:
    image: mich43l/postgresql
    container_name: pg
    environment:
      POSTGRES_PASSWORD: "secret"
      POSTGRES_ALLOW_EXTERNAL: "1"
      PG_ALLOWED_CIDRS: "127.0.0.1/32,::1/128,172.18.0.0/16,192.168.0.0/16"
      POSTGRES_PORT: "5432"
      POSTGRES_LOG_STATEMENT: "all"
      LANG: "C.UTF-8"
      LC_ALL: "C.UTF-8"
    ports:
      - "2345:5432"  # host:container
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./docker-entrypoint.sh:/usr/local/bin/docker-entrypoint.sh:ro
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d postgres || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 10

volumes:
  pgdata: {}
```