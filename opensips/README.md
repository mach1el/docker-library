# OpenSIPS Docker Image

![Debian](https://img.shields.io/badge/Debian-D70A53?style=for-the-badge&logo=debian&logoColor=white)
![OpenSips](https://img.shields.io/badge/OpenSips-3DDC84?style=for-the-badge&logo=opensips&logoColor=white)
![imgsize](https://img.shields.io/docker/image-size/mich43l/opensips/latest?color=red&style=flat-square)
![dockerautomated](https://img.shields.io/docker/automated/mich43l/opensips?style=flat-square)

This Docker image provides a pre-configured OpenSIPS environment, simplifying deployment and ensuring consistency. It's built on Debian Bookworm and includes many commonly used OpenSIPS modules, along with the `opensips-cli` for command-line interaction.

[mich43l/opensips](https://hub.docker.com/repository/docker/mich43l/opensips/general)

[mich43l/opensips-cp](https://hub.docker.com/repository/docker/mich43l/opensips-cp/general)

## Features

* **Debian Bookworm Base:** Provides a stable and up-to-date foundation.
* **OpenSIPS Version:**  Uses a configurable OpenSIPS version (default: 3.4).  Set the `OPENSIPS_VERSION` build argument to change this.
* **Comprehensive Module Set:** Includes a large selection of OpenSIPS modules (see Dockerfile for the full list).
* **OpenSIPS CLI:** The OpenSIPS command-line interface is included for easy management and troubleshooting.  Disable with `OPENSIPS_CLI=false` build argument.
* **Timezone Configuration:**  Sets the timezone within the container using the `TZ` environment variable.
* **Configuration:**  Includes a default OpenSIPS configuration located at `/etc/opensips/opensips.cfg`.  You can mount your own configuration file to this location.
* **Service Management:**  Uses `/etc/service` and a run script for managing the OpenSIPS service.

## Usage

### Building the Image

Clone this repository and build the Docker image:

```bash
git clone [https://github.com/your-username/opensips-docker.git](https://www.google.com/search?q=https://github.com/your-username/opensips-docker.git)  # Replace with your repo URL
cd opensips-docker
docker build -t opensips:latest .
```

You can customize the OpenSIPS version by setting the OPENSIPS_VERSION build argument:

```bash
docker build -t opensips:3.5 -f Dockerfile --build-arg OPENSIPS_VERSION=3.5 .
```

To disable the OpenSIPS CLI, use:

```bash
docker build -t opensips:no-cli -f Dockerfile --build-arg OPENSIPS_CLI=false .
```

Running the Container
Run the Docker container, mapping port 5060 (UDP) and setting the timezone:

```bash
docker run -d -p 5060:5060/udp -e TZ="Your/Timezone" -v /path/to/your/opensips.cfg:/etc/opensips/opensips.cfg opensips:latest
```

> Replace Your/Timezone with your desired timezone (e.g., America/New_York, Europe/London, Asia/Ho_Chi_Minh).  Mount your custom opensips.cfg file by replacing /path/to/your/opensips.cfg with the actual path.

## Using Docker Compose (Recommended)
For more complex deployments, using Docker Compose is recommended. Create a docker-compose.yml file:

```yaml
version: "3.9"  # Or your preferred version

services:
  opensips:
    image: opensips:latest
    ports:
      - "5060:5060/udp"
    environment:
      TZ: "Your/Timezone"
    volumes:
      - ./your_opensips_config:/etc/opensips/opensips.cfg # Mount your config
    restart: always # Optional: Restart policy
```

Then, start the container using Docker Compose:

```bash
docker-compose up -d
```
Customizing the Configuration
The default OpenSIPS configuration is located at /etc/opensips/opensips.cfg inside the container.  You can customize this configuration by mounting your own file to this path using the -v flag (as shown in the examples above).

# OpenSIPS Control Panel Docker Image

## Overview
This Dockerfile builds a containerized environment for the OpenSIPS Control Panel (OpenSIPS-CP) running on Debian Bookworm with Apache2 and PostgreSQL support.

## Features
- Runs Apache2 as the web server
- Configures OpenSIPS Control Panel (version 9.3.4)
- Uses PostgreSQL as the database backend
- Prepares OpenSIPS-CP for database initialization
- Automatically configures OpenSIPS-CP database parameters
- Runs Apache in the foreground

## Requirements
- Docker
- Docker Compose (optional)
- PostgreSQL database instance

## Environment Variables
The following environment variables are used to configure OpenSIPS-CP:

| Variable       | Default Value | Description |
|---------------|--------------|-------------|
| `DB_DRIVER`   | `pgsql`      | Database driver to use |
| `PG_HOST`     | `localhost`  | PostgreSQL host |
| `PG_PORT`     | `5432`       | PostgreSQL port |
| `PG_USER`     | `opensips`   | Database user |
| `PG_PASSWORD` | `opensipsrw` | Database password |
| `PG_DATABASE` | `opensips`   | OpenSIPS database name |
| `OPENSIPS_IP` | `127.0.0.1`  | OpenSIPS instance IP address |

## Building the Docker Image
To build the container image:

```sh
docker build -t opensips-cp .
```

## Running the Container
Run the container with:

```sh
docker run -d \
  --name opensips-cp \
  -e PG_HOST=your_postgresql_host \
  -e PG_USER=your_db_user \
  -e PG_PASSWORD=your_db_password \
  -e PG_DATABASE=your_db_name \
  -e OPENSIPS_IP=your_opensips_ip \
  -p 80:80 \
  opensips-cp
```

## Mounting Volumes
To persist configuration files and data, you can mount the following volumes:

```sh
docker run -d \
  --name opensips-cp \
  -v /your/local/opensips:/etc/opensips \
  -v /your/local/apache2:/etc/apache2 \
  -v /your/local/opensips-cp:/var/www/html/opensips-cp \
  -e PG_HOST=your_postgresql_host \
  -e PG_USER=your_db_user \
  -e PG_PASSWORD=your_db_password \
  -e PG_DATABASE=your_db_name \
  -e OPENSIPS_IP=your_opensips_ip \
  -p 80:80 \
  opensips-cp
```

## Database Initialization
The container automatically checks if the OpenSIPS-CP schema is present in the database. If not, it initializes it. Ensure that the database credentials are correctly set for successful initialization.

## Logs and Debugging
To check the container logs:

```sh
docker logs -f opensips-cp
```

## Stopping and Removing the Container
To stop the running container:

```sh
docker stop opensips-cp
```

To remove the container:

```sh
docker rm opensips-cp
```

## License
This project is licensed under the MIT License.

# Contributing
Contributions are welcome!  Please submit pull requests for any improvements or bug fixes.

# Dialplan Routing Logic

This note explains how inbound INVITEs are routed using the **OpenSIPS dialplan** in this stack. It focuses on what the dialplan rules must return, how they’re parsed, and the exact points where routing decisions are taken. Examples and operational tips are included at the end.

> TL;DR: We use `dp_translate(1, ...)` to decide *where* to send a call based on the called user (DID). Rules may return either **attrs** (preferred) or a **replacement** value. From this, we build a clean R‑URI like `sip:<did>@<host>:<port>` and relay the call.

---

## 1) Call flow overview

1. **Early gate for open‑relay**

   * For requests not targeting our domains, we **only transit** if `dp_translate(1, ...)` matches for either `$rU` or `$tU`. Otherwise we 403.
2. **INVITE entry point**

   * On `INVITE`, the script drops into `route(DID_ROUTING)`.
3. **Blacklist check**

   * Before hitting dialplan, the called user `$rU` is checked via `check_blacklist("userblacklist")`; blacklisted numbers get `504` and an ACC log entry.
4. **Select DID**

   * DID is taken from `$tU` (To: username) if present, else `$rU`.
5. **Dialplan match**

   * We call `dp_translate(1, did, repl, attrs)`.
   * If **no match** ⇒ `404 No route for DID`.
6. **Build target**

   * Preferred: parse `attrs` keys `host`, `port`, `proto`.
   * Fallback: interpret `repl` as either a full `sip:` URI, a `host:port` pair, or just `host`.
   * Default port ⇒ `5060`.
7. **Finalize & relay**

   * We set `R-URI = sip:<did>@<host>:<port>` and add helpful headers (`X-Orig-DID`, `Diversion`).
   * Media handling (RTPProxy) is armed in `route[relay]` / `onreply_route[handle_nat]`.

```
REQ → route{} → (anti-relay via dp check) → INVITE → route(DID_ROUTING)
     → blacklist? → DID selection → dp_translate(1, …)
     → build R-URI from attrs|repl → route(relay)
```

---

## 2) What your dialplan rules must return

We use **DPID = 1**. Each rule can set either:

### A) `attrs` (recommended)

Return a semicolon-separated list:

```
attrs = "host=sbc01.example.local;port=5060;proto=udp"
```

Recognized keys:

* `host` (required if using attrs)
* `port` (optional; defaults to `5060`)
* `proto` (optional; informational; URI transport param is **not** forced by default)

### B) `repl` (fallback)

Set one of:

* A full **SIP URI**: `repl = "sip:sbc01.example.local:5060"` → used directly.
* A **host:port** pair: `repl = "sbc01.example.local:5070"` → parsed into host/port.
* A bare **host**: `repl = "sbc01.example.local"` → port defaults to `5060`.

> If both `attrs` and `repl` are present, **attrs win** (we parse them first). If the resulting host is empty, we fail fast with `500 DP Misconfigured` and ACC note.

---

## 3) How the DID is chosen

* Primary: `$tU` (To header’s username)
* Fallback: `$rU` (R‑URI username)

This lets you write dialplan rules against the number that users *see* in To:, while remaining resilient if To: is empty.

---

## 4) Anti‑relay guard using dialplan

If a request targets a foreign domain (`!is_myself($rd)` and `!is_myself($fd)`), we will **only** allow transit when `dp_translate(1, $rU)` **or** `dp_translate(1, $tU)` returns a match. Otherwise we `403 Forbidden`. This means **dialplan itself is the allow‑list** for transit calls.

**Implication:** ensure you have at least a permissive catch-all rule (or explicit patterns) for the ranges you intend to relay.

---

## 5) R‑URI construction & headers

Once a rule matches, we:

* Build `sip:<did>@<host>:<port>` (no transport param by default).
* Add headers:

  * `X-Orig-DID: <did>` (for downstream debugging)
  * `Diversion: <sip:<did>@<orig_domain>>;reason=unconditional;…` (useful for PBX features / compliance)

> You can uncomment the TLS/TCP transport bits if you want to append `;transport=` based on `attrs.proto`.

---

## 6) Accounting fields

We record via `acc` with these **extra fields**:

* `src_ip` – source IP (`$si`)
* `dst_ip` – chosen target host
* `agent` – `$rU` at INVITE time
* `prefix` – derived from `$rU` length (10/12/13/14 digits → 0/2/3/4-digit prefix)
* `carrier` – defaults to `"Undefined"` (set it from dialplan if needed)

You can enrich `carrier` using `attrs` (e.g., `carrier=hcvn_core`) and map it in script before relay.

---

## 7) Blacklist integration

Before dialplan evaluation, we call `check_blacklist("userblacklist")` on `$rU`.

* Match ⇒ `504 Blacklisted` + `acc_db_request("Blacklisted", "acc")`.
* Miss ⇒ continue.

Ensure your `userblacklist` table contains the formats you intend to block (exact numbers, prefixes via patterns, etc.).

---

## 8) Authoring dialplan rules (DB schema & examples)

OpenSIPS’s default `dialplan` table (PostgreSQL) includes fields like:

* `dpid`, `pr` (priority), `match_op`, `match_exp`, `subst_exp`, `repl_exp`, `attrs`

### Example 1 – Route a 10‑digit DID to SBC A

```
dpid=1  pr=10  match_op=4  match_exp=^\d{10}$  repl_exp=  attrs=host=sbc-a.local;port=5060
```

### Example 2 – Specific range to SBC B on 5070

```
dpid=1  pr=20  match_op=4  match_exp=^089\d{7}$  attrs=host=sbc-b.local;port=5070;proto=udp
```

### Example 3 – Full SIP URI in repl

```
dpid=1  pr=30  match_op=4  match_exp=^0938269\d{3}$  repl_exp=sip:sbc-c.local:5062
```

> Prefer **attrs**—they are explicit and less error‑prone. Use priorities (`pr`) to order rules from most to least specific.

---

## 9) Operational commands

* **Reload dialplan rules** (no restart):

  ```sh
  opensipsctl fifo dp_reload
  ```
* **Check that we matched dialplan**: look for log lines like

  * `DP: in='<did>'  repl='[...]'  attrs='[...]'`
  * `DP: building URI with host='…' port='…'`
* **Common failure logs**

  * `DP: no match for DID='…'` → add/adjust a rule.
  * `DP matched but host is empty` → fix your rule to return `attrs.host` or a valid `repl`.

> Increase `log_level` temporarily if you need more verbosity during testing.

---

## 10) Testing tips

* **Basic reachability**

  ```sh
  sipsak -s sip:0123456789@<your-opensips-ip> -v
  ```
* **SIP OPTIONS** (check path through relay target once dialplan is set to return a full SIP URI):

  ```sh
  sipsak -s sip:0123456789@<your-opensips-ip> --method OPTIONS -v
  ```
* **NAT / RTP**
  Ensure `rtpproxy` is reachable and `rtpproxy_sock` matches your deployment. Watch for `RTPProxy offer/answer engaged` lines.

---

## 11) Security considerations

* Dialplan is used as the **allow‑list** for transit; keep it tight. Avoid overly broad catch‑alls unless you control upstreams.
* Maintain the `userblacklist` table regularly.
* Consider enabling IP allow‑listing via the `permissions` module (`address` table) *in addition* to dialplan gating.

---

## 12) Locale & encoding

If your surrounding tooling (importers/exporters, UI, etc.) needs explicit locale/encoding, keep these environment variables documented and consistent:

* `CC_LANG` – e.g., `en_US.UTF-8` or `vi_VN.UTF-8`
* `CC_ENCODING` – e.g., `UTF-8`

These do **not** affect OpenSIPS routing itself but help keep auxiliary scripts and data pipelines (e.g., dialplan loaders) consistent.

---

## 13) FAQ

**Q: What happens if my rule returns both `attrs` and a `repl`?**
A: We parse `attrs` first and only fall back to `repl` if `attrs.host` is empty.

**Q: Can I direct some ranges to TCP/TLS?**
A: Yes—set `proto=tcp|tls` in `attrs` and enable the lines that append `;transport=` when building the R‑URI.

**Q: I need different policy for `$rU` vs `$tU`.**
A: Create separate rule sets or patterns and check in script before calling `dp_translate`; or encode the intent in `attrs` (e.g., `policy=to_user`) and branch accordingly.

---

## 14) Change safely

1. Create/update rules in DB (DPID=1).
2. `opensipsctl fifo dp_reload`.
3. Test with a non‑critical DID first.
4. Watch logs and ACC table for `carrier`, `prefix`, `src_ip`, `dst_ip`.

---

### Appendix: Minimal rule cookbook

* **Send everything starting 089** → `attrs=host=sbc-b.local;port=5070`.
* **Send 10‑digit numbers to SBC‑A** → `attrs=host=sbc-a.local`.
* **Special DID 19001234 to a full SIP URI** → `repl=sip:special-gw.local:5080`.

> When in doubt, prefer `attrs` and keep patterns as specific as possible.
