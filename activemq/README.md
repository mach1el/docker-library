# ActiveMQ on container 

Base on `openjdk:bullseye` from [OpenJDK](https://hub.docker.com/_/openjdk) 

## Build 
```
docker buildx build --platform linux/amd64 --build-arg VERSION=5.18.3 -t activemq .
```

## Usage

Run as default
```
docker run -tid --name=activemq -p 61616:61616 mich43l/activemq
```

Run with variables
```
docker run -tid \
  --name=activemq \
  -p 61616:61616 \
  -e ACTIVEMQ_USERNAME=adminmq \
  -e ACTIVEMQ_PASSWORD=adminmqpassword \
  -e ACTIVEMQ_WEBADMIN_USERNAME=rootmq \
  -e ACTIVEMQ_WEBADMIN_PASSWORD=toormq \
  mich43l/activemq
```

## Image tags
```
mich43l/activemq:latest (5.18.3)
mich43l/activemq:5.18.3
mich43l/activemq:5.18.1
mich43l/acitvemq:5.16.7
mich43l/activemq:5.16.6
```

## Variables

| Environment Variable          | Default | Description                                                                  |
|:------------------------------|:--------|:-----------------------------------------------------------------------------|
| ACTIVEMQ_USERNAME             | system  | [Security](https://activemq.apache.org/security) (credentials.properties)    |
| ACTIVEMQ_PASSWORD             | manager | [Security](https://activemq.apache.org/security) (credentials.properties)    |
| ACTIVEMQ_WEBADMIN_USERNAME    | admin   | [WebConsole](https://activemq.apache.org/security) (jetty-realm.properties)  |
| ACTIVEMQ_WEBADMIN_PASSWORD    | admin   | [WebConsole](https://activemq.apache.org/security) (jetty-realm.properties)  |