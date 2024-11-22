# ActiveMQ Docker Image
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Alpine Linux](https://img.shields.io/badge/Alpine_Linux-%230D597F.svg?style=for-the-badge&logo=alpine-linux&logoColor=white)
![Java](https://img.shields.io/badge/amazon-corretto-%23FF0000.svg?style=for-the-badge&logo=java&logoColor=white)
![ActiveMQ](https://img.shields.io/badge/active-mq-%23B7178C.svg?style=for-the-badge&logo=activemq&logoColor=white)

Base on Alpine OS `mich43l/os:alpine` from [mich43l](https://hub.docker.com/r/mich43l/os). This image implemented [Java Corretto](https://aws.amazon.com/corretto/?filtered-posts.sort-by=item.additionalFields.createdDate&filtered-posts.sort-order=desc) for the Java binary. The `5.x.x` version is using Java 11 and for `6.x.x` version it will using Java 17. 

## Features

- **ActiveMQ Version**: Configurable via build argument (`VERSION`), defaults to `6.1.2`.
- **Java Runtime**: Powered by Amazon Corretto OpenJDK (`17.0.11.9.1` by default).
- **Alpine Base**: Built on `mich43l/os:alpine` for efficiency and small image size.
- **Preconfigured Ports**: Common ActiveMQ ports are exposed by default.
- **Custom Work Directory**: ActiveMQ is set to run from `/opt/activemq`.

### Build Image

To build the image locally:

```bash
docker buildx build \
  --tag mich43l/activemq \
  --build-arg VERSION=6.1.2 \
  --build-arg JAVA_VERSION=17.0.11.9.1 .
```

## Supported tags
-	`v5.18.3`
- `v5.18.4`
- `v6.1.2`
- [More Tags](https://hub.docker.com/r/mich43l/activemq/tags)

## Run Image

* Run as default:

  ```bash
  docker run -tid --name=activemq -p 61616:61616 mich43l/activemq
  ```

* Run with variables:

  ```bash
  docker run -tid \
    --name=activemq \
    -p 61616:61616 \
    -e ACTIVEMQ_USERNAME=adminmq \
    -e ACTIVEMQ_PASSWORD=adminmqpassword \
    -e ACTIVEMQ_WEBADMIN_USERNAME=rootmq \
    -e ACTIVEMQ_WEBADMIN_PASSWORD=toormq \
    mich43l/activemq
  ```

## Variables

| Environment Variable          | Default | Description                                                                  |
|:------------------------------|:--------|:-----------------------------------------------------------------------------|
| ACTIVEMQ_USERNAME             | system  | [Security](https://activemq.apache.org/security) (credentials.properties)    |
| ACTIVEMQ_PASSWORD             | manager | [Security](https://activemq.apache.org/security) (credentials.properties)    |
| ACTIVEMQ_WEBADMIN_USERNAME    | admin   | [WebConsole](https://activemq.apache.org/security) (jetty-realm.properties)  |
| ACTIVEMQ_WEBADMIN_PASSWORD    | admin   | [WebConsole](https://activemq.apache.org/security) (jetty-realm.properties)  |