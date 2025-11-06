# CloudBeaver CE – Oracle-ready Image (custom build)

[![Docker Image](https://img.shields.io/docker/v/mich43l/cloudbeaver?sort=semver)](https://hub.docker.com/r/mich43l/cloudbeaver/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/mich43l/cloudbeaver)](https://hub.docker.com/r/mich43l/cloudbeaver)

[![Container](https://img.shields.io/badge/container-docker%20%7C%20podman-2496ED?logo=docker)](#)
[![CloudBeaver](https://img.shields.io/badge/CloudBeaver-ready-00B6B8)](https://dbeaver.com/docs/cloudbeaver/)
[![Oracle JDBC](https://img.shields.io/badge/Oracle%20JDBC-ojdbc17-brightgreen)](#)
[![Wallet](https://img.shields.io/badge/Wallet%20(TCPS)-supported-success)](#)

A production-friendly CloudBeaver (web SQL client) image that **bundles Oracle JDBC** (plus a few common JDBC drivers) so you can run fully offline/air-gapped. It keeps CloudBeaver’s **built-in drivers** (like H2 for internal metadata) intact.

> ✅ Works with Docker or Podman.  
> ✅ Oracle thin + Wallet/TCPS supported.  
> ✅ No need to mount custom drivers at runtime.

---

## What’s inside

- Base: `dbeaver/cloudbeaver:<tag>`  
- Preloaded drivers:
  - Oracle JDBC: `ojdbc17-<version>.jar`
  - Wallet/TCPS libs: `oraclepki-<version>.jar`, `osdt_core-<version>.jar`, `osdt_cert-<version>.jar`
  - Extras (optional): PostgreSQL, MySQL, MS SQL Server, H2 (fallback)
- Healthcheck, clean volumes, and a default port mapping **5050 → 8978**

> **Important:** We never overwrite `/opt/cloudbeaver/drivers`. Built-in drivers remain available.

---

## Repository layout

```
.
├─ Dockerfile
├─ docker-compose.yml
├─ wallets/              # put Oracle Wallet(s) here (unzipped directories)
└─ conf/
   └─ cloudbeaver.conf   # optional; only if you want to pin server config
```

---

## Quick start

1) **Build & run** (Docker):
```bash
docker compose build
docker compose up -d
```

Podman:
```bash
podman compose build
podman compose up -d
# or: podman-compose up -d
```

2) Open **http://<host>:5050**  
   Login with the bootstrap admin (see `docker-compose.yml`). Change the password immediately.

3) **Add a connection → Oracle** and use one of the JDBC URL patterns below.

---

## JDBC URL patterns

### On-prem / thin driver
```
jdbc:oracle:thin:@//HOSTNAME:1521/SERVICE_NAME
```
Example: `jdbc:oracle:thin:@//db.example.com:1521/ORCLPDB1`

### Autonomous DB / Wallet (TCPS)
1. Unzip the wallet into `./wallets/yourdb/` (this is mounted read-only)
2. Use:
```
jdbc:oracle:thin:@dbname_high?TNS_ADMIN=/opt/cloudbeaver/wallets/yourdb
```

> If you prefer a TNS alias, set `TNS_ADMIN` similarly and use  
> `jdbc:oracle:thin:@YOUR_TNS_ALIAS`

---

## Files in this repo

### Dockerfile
- Extends the official image
- Downloads Oracle JDBC and wallet libs into `/opt/cloudbeaver/drivers/oracle`
- Adds optional JDBC drivers into `/opt/cloudbeaver/drivers/extra`
- Leaves built-in drivers untouched

### docker-compose.yml
- Builds the image (you can pin tags/versions via build args)
- Publishes **port 5050**
- Persists **workspace** at `/opt/cloudbeaver/workspace`
- Mounts **wallets** read-only
- Includes a simple HTTP healthcheck

> **Note:** We intentionally **do not** mount `/opt/cloudbeaver/drivers` from the host.  
> That would overwrite built-in drivers and break startup.

---

## Configuration

### Environment variables
- `CB_SERVER_NAME` – display name in the UI
- `CB_SERVER_URL` – base URL (set your public URL if behind reverse proxy)
- `CB_ADMIN_NAME`, `CB_ADMIN_PASSWORD` – bootstrap admin user
- `TZ` – container timezone (optional)

> For production, store secrets in Docker/Podman **secrets** or your vault of choice.

### Volumes
- `cb_workspace:/opt/cloudbeaver/workspace` – user settings, saved connections, etc.
- `./wallets:/opt/cloudbeaver/wallets:ro` – put Oracle Wallet directories here

---

## Reverse proxy (optional)

Example Nginx (TLS termination + pass through):

```nginx
server {
  listen 443 ssl http2;
  server_name cloudbeaver.example.com;

  ssl_certificate     /etc/ssl/certs/fullchain.pem;
  ssl_certificate_key /etc/ssl/private/privkey.pem;

  location / {
    proxy_pass http://127.0.0.1:5050/;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto https;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }
}
```

If you front CloudBeaver with SSO (e.g., oauth2-proxy/Keycloak) using header auth, enable **Reverse proxy** mode in CloudBeaver’s Server Settings and forward a stable user header (e.g., `X-Forwarded-User`).

---

## Troubleshooting

### `can't load driver class 'org.h2.Driver'`
You accidentally replaced `/opt/cloudbeaver/drivers` with a host mount.  
**Fix:** don’t mount that path. Use this image as-is, or mount only subfolders (e.g., `/opt/cloudbeaver/wallets`). If you must restore H2 temporarily, include `h2-<ver>.jar` under the mounted drivers, then remove the mount.

### Oracle Wallet fails to connect (TCPS)
- Ensure wallet files (including `tnsnames.ora`, `sqlnet.ora`, `ewallet.sso`) are present and readable
- Confirm your JDBC URL has the correct `TNS_ADMIN` path inside the **container**
- Check firewalls for `1522/TCPS` (or your ADB port)

### “Driver not found” in UI
This image already ships the jars. If the UI still can’t bind, restart the container once after first run so CloudBeaver rescans the drivers directory.

---

## Swarm / Registry

1) Build and push:
```bash
docker build -t registry.example.com/tools/cloudbeaver-oracle:25.2.0 .
docker push registry.example.com/tools/cloudbeaver-oracle:25.2.0
```

2) Minimal `stack.yml`:
```yaml
version: "3.9"
services:
  cloudbeaver:
    image: registry.example.com/tools/cloudbeaver-oracle:25.2.0
    ports: ["5050:8978"]
    environment:
      CB_SERVER_NAME: "HC CloudBeaver"
      CB_SERVER_URL: "https://cloudbeaver.example.com/"
      CB_ADMIN_NAME: "admin"
      CB_ADMIN_PASSWORD: "change_me"
    volumes:
      - cb_workspace:/opt/cloudbeaver/workspace
      - ./wallets:/opt/cloudbeaver/wallets:ro
    deploy:
      replicas: 1
      restart_policy: { condition: on-failure }
volumes:
  cb_workspace:
```

---

## Upgrades

- Bump `CB_TAG` (base image) and/or the JDBC driver versions in the build args, rebuild, then recreate the service.
- Backup `cb_workspace` before major upgrades.

---

## Security hardening checklist

- Put `CB_ADMIN_PASSWORD` in a secret or vault
- Run behind TLS (reverse proxy or LB)
- Restrict access via SSO or network ACLs
- Keep wallets **read-only** and controlled
- Regularly update the base image and JDBC libraries

---

## License notes

Oracle JDBC artifacts are distributed by Oracle under their terms.  
Use according to your organization’s licensing/compliance guidelines.

---

## Commands recap

```bash
# Build & run (Docker)
docker compose build && docker compose up -d

# Logs
docker compose logs -f

# Stop
docker compose down

# Podman equivalent
podman compose build && podman compose up -d
```
