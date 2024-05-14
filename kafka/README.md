# Kafka on container
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Alpine Linux](https://img.shields.io/badge/Alpine_Linux-%230D597F.svg?style=for-the-badge&logo=alpine-linux&logoColor=white)
![Apache Kafka](https://img.shields.io/badge/Apache%20Kafka-000?style=for-the-badge&logo=apachekafka)

[![Docker pulls](https://img.shields.io/docker/pulls/mich43l/kafka)](https://hub.docker.com/r/mich43l/kafka)
![Docker Iamge](https://img.shields.io/docker/image-size/mich43l/kafka)

# Supported tags
-	`v2.8.2`
- [More Tags](https://hub.docker.com/r/mich43l/kafka/tags)

## Run `Kafka` server

* Starting zookeeper server for the Kafka broker
```
docker run -tid --name=zookeeper -p 2181:2181 -e ALLOW_ANONYMOUS_LOGIN=yes bitnami/zookeeper
```
* Starting kafka server
```
docker run -tid --name=kafka -p 9092:9092 mich43l/kafka
```

## Variables

| Environment Variable       | Default | Description                                                                         |
|:---------------------------|:--------|:------------------------------------------------------------------------------------|
| KAFKA_LISTENERS            | null    | Configure LISTENERS for Kafka broker. Eg. `PLAINTEXT://:9092`                       |
| KAFKA_ADVERTISED_LISTENERS | null    | Configure ADVERTISED for external connection. Eg. `PLAINTEXT://$(MY_HOST_IP):30992` |
| KAFKA_ZOOKEEPER_CONNECT    | null    | Set zookeeper host. Eg. `zookeeper:2181`                                            |
| KAFKA_HEAP_OPTS            | null    | Kafka Java Heap size. For example `-Xmx512m -Xms512m`                               |