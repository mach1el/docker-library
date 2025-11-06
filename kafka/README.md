# Kafka on container
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Alpine Linux](https://img.shields.io/badge/Alpine_Linux-%230D597F.svg?style=for-the-badge&logo=alpine-linux&logoColor=white)
![Apache Kafka](https://img.shields.io/badge/Apache%20Kafka-000?style=for-the-badge&logo=apachekafka)
[![Docker pulls](https://img.shields.io/docker/pulls/mich43l/kafka)](https://hub.docker.com/r/mich43l/kafka)
![Docker Iamge](https://img.shields.io/docker/image-size/mich43l/kafka)

This repository provides the Dockerfile and configuration for building a lightweight Kafka container based on Alpine Linux. The container is optimized for minimal footprint and includes Apache Kafka with Amazon Corretto OpenJDK.

---

## ✨ Key Features

- **Runtime guardrails:** Verifies Java availability and required env vars.
- **Config-safe:** Backs up `server.properties` before patching.
- **Env-driven config:** Updates listeners, advertised listeners, ZK/KRaft settings, log dirs, partitions, retention, auto-create, etc.
- **KRaft storage formatting:** Auto-generates or uses a provided `KAFKA_CLUSTER_ID`; formats via `kafka-storage.sh`.
- **Graceful shutdown:** Traps `SIGTERM/SIGINT`, forwards to Kafka, and propagates exit code.
- **Idempotent runs:** Skips storage format if `meta.properties` already exists (i.e., persisted volume).
- **Non-root friendly:** Uses `gosu mich43l` if running as root to drop privileges.

---

## 📁 Paths & Assumptions

The entrypoint expects:

- `KAFKA_BIN` → Kafka binaries (`kafka-server-start.sh`, `kafka-storage.sh`)
- `KAFKA_CONF` → Config directory containing `server.properties`
- `KAFKA_DATA` → Data directory for Kafka logs (`${KAFKA_DATA}/kafka-logs`)

> The script creates `${KAFKA_DATA}/kafka-logs` if missing.  
> If running as root, it attempts `chown -R mich43l:mich43l` (non-fatal if user/group aren’t present).

---

## Supported tags
-	`v2.8.2`
- `v3.6.2`
- `v3.8.0`
- `v4.1.0`
- [More Tags](https://hub.docker.com/r/mich43l/kafka/tags)

---

## Build the Image

To build the image locally:

```bash
docker buildx build \
  --tag mich43l/kafka \
  --build-arg kafka_version=3.6.2 \
  --build-arg scala_version=2.13 .
```

---

## Run `Kafka` server

* Starting zookeeper server for the Kafka broker
  ```bash
  docker run -tid \
    --name zookeeper \
    --publish 2181:2181 \
    --env ALLOW_ANONYMOUS_LOGIN=yes \
    bitnami/zookeeper
  ```

* Starting kafka server
  ```bash
  docker run -d \
    --name kafka \
    -p 9092:9092 \
    -e KAFKA_BROKER_ID=1 \
    -e KAFKA_ZOOKEEPER_CONNECT=localhost:2181 \
    -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092 \
    -e KAFKA_LOG_DIRS=/opt/kafka/data \
    -v /path/to/config:/opt/kafka/config \
    -v /path/to/data:/opt/kafka/data \
    mich43l/kafka
  ```

---

## 🔧 Environment Variables (updated)

> The entrypoint **auto-detects mode**:
> - If `KAFKA_ZOOKEEPER_CONNECT` is set → **ZooKeeper mode**
> - Else if any of `KAFKA_NODE_ID`, `KAFKA_CLUSTER_ID`, `KAFKA_CONTROLLER_QUORUM_VOTERS` is set → **KRaft mode**
> - Else → **defaults to ZooKeeper** (warns)
>
> For each key, the script will **uncomment**, **replace**, or **append** the property in `server.properties` (last one wins).

### Core (required in both modes)
| Variable     | Required | Description                                                       | Example            |
|--------------|----------|-------------------------------------------------------------------|--------------------|
| `KAFKA_CONF` | ✅       | Path to config dir containing `server.properties`                 | `/etc/kafka`       |
| `KAFKA_BIN`  | ✅       | Path to Kafka bin scripts (`kafka-server-start.sh`, etc.)         | `/opt/kafka/bin`   |
| `KAFKA_DATA` | ✅       | Data root; script sets `log.dirs` to `${KAFKA_DATA}/kafka-logs`   | `/var/lib/kafka`   |

### Networking / Listeners
| Variable                            | Mode     | Default (if unset)                                                      | Notes |
|-------------------------------------|----------|-------------------------------------------------------------------------|-------|
| `KAFKA_LISTENERS`                   | both     | **KRaft only**: `PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093`    | Appended if missing. |
| `KAFKA_ADVERTISED_LISTENERS`        | both     | _none_                                                                  | Must be reachable by clients. |
| `KAFKA_LISTENER_SECURITY_PROTOCOL_MAP` | both  | **KRaft only**: `CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT`              | Sets `listener.security.protocol.map`. |
| `KAFKA_CONTROLLER_LISTENER_NAMES`   | KRaft    | `CONTROLLER`                                                            | Sets `controller.listener.names`. |

### Mode selection
| Variable                      | Mode     | Required | Default / Behavior                                        |
|-------------------------------|----------|----------|-----------------------------------------------------------|
| `KAFKA_ZOOKEEPER_CONNECT`     | ZooKeeper| ✅       | If set, script removes KRaft keys from config.            |
| `KAFKA_NODE_ID`               | KRaft    | ✅       | Script exits if missing in KRaft mode.                    |
| `KAFKA_CLUSTER_ID`            | KRaft    | ❌       | If absent and not formatted, script **generates** UUID.   |
| `KAFKA_CONTROLLER_QUORUM_VOTERS` | KRaft | ❌       | Defaults to `${KAFKA_NODE_ID}@localhost:9093` (single node). |
| `KAFKA_PROCESS_ROLES`         | KRaft    | ❌       | `broker,controller` (single-node default).                |

### Broker behavior
| Variable                     | Mode  | Default | Description                              |
|------------------------------|-------|---------|------------------------------------------|
| `KAFKA_LOG_RETENTION_HOURS`  | both  | _none_  | Sets `log.retention.hours`.              |
| `KAFKA_NUM_PARTITIONS`       | both  | _none_  | Sets `num.partitions`.                   |
| `KAFKA_AUTO_CREATE_TOPICS`   | both  | _none_  | Sets `auto.create.topics.enable`.        |

### JVM / Performance
| Variable                      | Mode | Default         | Description                            |
|-------------------------------|------|-----------------|----------------------------------------|
| `KAFKA_HEAP_OPTS`             | both | _none_          | e.g. `-Xms512m -Xmx512m`.              |
| `KAFKA_JVM_PERFORMANCE_OPTS`  | both | _none_          | Extra JVM flags (e.g. GC, server mode).|

---

### Quick examples

**KRaft (single node)**
```yaml
environment:
  KAFKA_CONF: /etc/kafka
  KAFKA_BIN: /opt/kafka/bin
  KAFKA_DATA: /var/lib/kafka

  KAFKA_NODE_ID: "1"
  KAFKA_LISTENERS: "PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093"
  KAFKA_ADVERTISED_LISTENERS: "PLAINTEXT://your-host:9092"
  KAFKA_CONTROLLER_QUORUM_VOTERS: "1@kafka:9093"
  KAFKA_CONTROLLER_LISTENER_NAMES: "CONTROLLER"
  KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: "CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT"

  KAFKA_HEAP_OPTS: "-Xms512m -Xmx512m"
  KAFKA_NUM_PARTITIONS: "3"
  KAFKA_AUTO_CREATE_TOPICS: "true"
  KAFKA_LOG_RETENTION_HOURS: "168"

---

## 🧩 Minimal `server.properties` templates

### KRaft (single node, combined controller+broker)
```properties
# roles
process.roles=broker,controller
node.id=1

# listeners
controller.listener.names=CONTROLLER
listeners=PLAINTEXT://:9092,CONTROLLER://:9093
listener.security.protocol.map=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT
inter.broker.listener.name=PLAINTEXT

# discovery
advertised.listeners=PLAINTEXT://localhost:9092
controller.quorum.voters=1@localhost:9093

# logs & defaults
log.dirs=/var/lib/kafka/kafka-logs
num.partitions=1
auto.create.topics.enable=truec
```

---

## 🐳 Docker Compose (KRaft single node)

> Controller port 9093 generally does not need to be published externally; it’s used by the KRaft quorum.

```yml
services:
  kafka:
    image: mich43l/kafka
    container_name: kafka
    hostname: kafka
    ports:
      - "9092:9092"   # client
      - "9093:9093"   # controller (optional to expose)
    environment:
      # Required
      KAFKA_CONF: /etc/kafka
      KAFKA_BIN: /opt/kafka/bin
      KAFKA_DATA: /var/lib/kafka

      # KRaft
      KAFKA_NODE_ID: "1"
      KAFKA_LISTENERS: "PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093"
      KAFKA_ADVERTISED_LISTENERS: "PLAINTEXT://localhost:9092"
      KAFKA_CONTROLLER_QUORUM_VOTERS: "1@kafka:9093"

      # Optional tuning
      KAFKA_HEAP_OPTS: "-Xms512m -Xmx512m"
      KAFKA_NUM_PARTITIONS: "3"
      KAFKA_AUTO_CREATE_TOPICS: "true"
      KAFKA_LOG_RETENTION_HOURS: "168"

    volumes:
      - ./server.properties:/etc/kafka/server.properties:ro
      - kafka-data:/var/lib/kafka
    restart: unless-stopped

volumes:
  kafka-data:
```

---

## 🐘 Compose (ZooKeeper mode, legacy)

```yml
version: "3.8"
services:
  zookeeper:
    image: bitnami/zookeeper:3.9
    environment:
      ALLOW_ANONYMOUS_LOGIN: "yes"
    ports: ["2181:2181"]
    restart: unless-stopped

  kafka:
    image: mich43l/kafka
    ports:
      - "9092:9092"
    environment:
      KAFKA_CONF: /etc/kafka
      KAFKA_BIN: /opt/kafka/bin
      KAFKA_DATA: /var/lib/kafka
      # ZooKeeper
      KAFKA_ZOOKEEPER_CONNECT: "zookeeper:2181"
      # Listeners
      KAFKA_LISTENERS: "PLAINTEXT://0.0.0.0:9092"
      KAFKA_ADVERTISED_LISTENERS: "PLAINTEXT://localhost:9092"
    volumes:
      - ./server.properties:/etc/kafka/server.properties:ro
      - kafka-data:/var/lib/kafka
    restart: unless-stopped

volumes:
  kafka-data:
```

---

## ▶️ Usage

## Build and start:

```bash
docker compose up --build -d
docker compose logs -f kafka
```

### Create a topic (example):

```bash
docker exec -it kafka kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --create --topic demo --partitions 3 --replication-factor 1
```

### Produce/consume:

```bash
docker exec -it kafka kafka-console-producer.sh --bootstrap-server localhost:9092 --topic demo
docker exec -it kafka kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic demo --from-beginning
```

---

## ❤️ Graceful Shutdown

The entrypoint traps SIGTERM and SIGINT, forwards them to the Kafka process, waits for exit, and returns the broker’s exit code.

---

## 🩺 Healthcheck (optional)

You can add this to your Compose service:

```yml
healthcheck:
  test: ["CMD", "bash", "-lc", "kafka-broker-api-versions.sh --bootstrap-server localhost:9092 >/dev/null 2>&1"]
  interval: 15s
  timeout: 5s
  retries: 10
  start_period: 20s
```

---

## 🧠 Notes & Gotchas — updated for the autodetect KRaft/ZooKeeper entrypoint

- **Mode auto-detection & default**
  - If `KAFKA_ZOOKEEPER_CONNECT` is set ➜ **ZooKeeper mode**.
  - Else if any of `KAFKA_NODE_ID`, `KAFKA_CLUSTER_ID`, or `KAFKA_CONTROLLER_QUORUM_VOTERS` is set ➜ **KRaft mode**.
  - Else ➜ **defaults to ZooKeeper** and logs a warning.
  - **KRaft requires `KAFKA_NODE_ID`.** The script exits if it’s missing.

- **Patching semantics (idempotent-friendly)**
  - For each property, the script will:
    1) **Uncomment** a `# key=...` line if present,
    2) **Replace** an existing `key=...` line,
    3) **Append** `key=value` to the end **if absent**.
  - This applies to keys like:
    - `listeners`, `advertised.listeners`
    - `zookeeper.connect`
    - `node.id`, `process.roles`
    - `controller.quorum.voters`, `controller.listener.names`
    - `listener.security.protocol.map`
    - `log.dirs`, `log.retention.hours`, `num.partitions`, `auto.create.topics.enable`
  - Kafka uses the **last occurrence wins** rule. Avoid manually duplicating keys; the script already appends when missing.

- **Mode-specific sanitization**
  - When **ZooKeeper mode** is chosen, the script **removes** KRaft keys:
    - `process.roles`, `node.id`, `controller.quorum.voters`, `controller.listener.names`.
  - When **KRaft mode** is chosen, the script **removes** `zookeeper.connect`.

- **KRaft defaults (if you didn’t provide them)**
  - `listeners=PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093`
  - `controller.listener.names=CONTROLLER`
  - `listener.security.protocol.map=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT`
  - `process.roles=broker,controller` (single-node default; override via `KAFKA_PROCESS_ROLES`)

- **Storage formatting (KRaft only)**
  - If `${KAFKA_DATA}/kafka-logs/meta.properties` **exists**, formatting is **skipped** (already formatted).
  - If missing, the script uses `KAFKA_CLUSTER_ID` or **generates** one and runs `kafka-storage.sh format`.
  - **Persist your data volume** so the meta file survives restarts.
  - Switching clusters/topologies (e.g., changing voters) may require **reformatting** or a clean data dir.

- **Listeners & reachability**
  - `advertised.listeners` **must be reachable** by clients. Use a real host/IP for external producers/consumers.
  - The **controller port (9093)** is for the KRaft quorum and typically shouldn’t be exposed publicly.

- **Baselines still required**
  - The script **patches** keys; it doesn’t generate a full `server.properties` from scratch.
  - Provide a minimal baseline for your chosen mode (KRaft or ZooKeeper).

- **Paths & ownership**
  - `log.dirs` is set to `${KAFKA_DATA}/kafka-logs`; the directory is created if missing.
  - If running as root, the script attempts `chown -R mich43l:mich43l` (non-fatal if user/group absent).
  - Make sure the image either has user `mich43l` or adjust the entrypoint and Dockerfile accordingly.

- **Runtime preconditions**
  - `java` must exist in `$PATH`; otherwise the entrypoint exits.
  - Required env: `KAFKA_CONF`, `KAFKA_BIN`, `KAFKA_DATA`. `server.properties` must exist in `KAFKA_CONF`.

- **Signals & lifecycle**
  - Uses `set -euo pipefail` for safer bash behavior.
  - Traps `SIGTERM`/`SIGINT`, forwards to Kafka, waits, and returns Kafka’s exit code.

- **Common foot-guns**
  - Duplicated keys in `server.properties`: Kafka takes the **last** one; your baseline + script appends may create multiple entries—prefer letting the script manage them.
  - Changing from ZooKeeper to KRaft (or vice-versa) without cleaning incompatible keys can cause confusing errors—this script removes the mode-specific opposites for you.
  - In container platforms, `advertised.listeners` must match how clients reach the broker (service DNS vs host IP).