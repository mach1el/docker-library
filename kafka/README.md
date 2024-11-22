# Kafka on container
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Alpine Linux](https://img.shields.io/badge/Alpine_Linux-%230D597F.svg?style=for-the-badge&logo=alpine-linux&logoColor=white)
![Apache Kafka](https://img.shields.io/badge/Apache%20Kafka-000?style=for-the-badge&logo=apachekafka)
[![Docker pulls](https://img.shields.io/docker/pulls/mich43l/kafka)](https://hub.docker.com/r/mich43l/kafka)
![Docker Iamge](https://img.shields.io/docker/image-size/mich43l/kafka)

This repository provides the Dockerfile and configuration for building a lightweight Kafka container based on Alpine Linux. The container is optimized for minimal footprint and includes Apache Kafka with Amazon Corretto OpenJDK.

## Features

- **Kafka Version**: Configurable via build argument (`kafka_version`), defaults to `3.0.0`.
- **Scala Version**: Compatible with the specified Kafka version (`2.13` by default).
- **Java Runtime**: Utilizes Amazon Corretto OpenJDK (`17.0.11.9.1` by default).
- **Alpine Base**: Built on `mich43l/os:alpine` for small size and efficiency.
- **Configurable Directories**:
  - `KAFKA_HOME`: `/opt/kafka`
  - `KAFKA_BIN`: `/opt/kafka/bin`
  - `KAFKA_CONF`: `/opt/kafka/config`
  - `KAFKA_DATA`: `/opt/kafka/data`

## Supported tags
-	`v2.8.2`
- `v3.6.2`
- `v3.8.0`
- [More Tags](https://hub.docker.com/r/mich43l/kafka/tags)

## Build the Image

To build the image locally:

```bash
docker buildx build \
  --tag mich43l/kafka \
  --build-arg kafka_version=3.6.2 \
  --build-arg scala_version=2.13 .
```

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

## Security

This image follows best practices for security:

* Runs with a minimal Alpine-based system.
* Downloads dependencies from trusted sources with checksum validation.
* Kafka directories are owned by the non-root user `mich43l`.

## Variables

| Environment Variable       | Default | Description                                                                         |
|:---------------------------|:--------|:------------------------------------------------------------------------------------|
| KAFKA_LISTENERS            | null    | Configure LISTENERS for Kafka broker. Eg. `PLAINTEXT://:9092`                       |
| KAFKA_ADVERTISED_LISTENERS | null    | Configure ADVERTISED for external connection. Eg. `PLAINTEXT://$(MY_HOST_IP):30992` |
| KAFKA_ZOOKEEPER_CONNECT    | null    | Set zookeeper host. Eg. `zookeeper:2181`                                            |
| KAFKA_HEAP_OPTS            | null    | Kafka Java Heap size. For example `-Xmx512m -Xms512m`                               |