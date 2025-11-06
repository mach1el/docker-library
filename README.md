# Docker library
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Cloudbeaver](https://img.shields.io/badge/cloudbeaver-00B6B8.svg?style=for-the-badge&logo=cloudbeaver&logoColor=white&labelColor=0b1221)
![Debian](https://img.shields.io/badge/Debian-D70A53?style=for-the-badge&logo=debian&logoColor=white)
![Alpine Linux](https://img.shields.io/badge/Alpine_Linux-%230D597F.svg?style=for-the-badge&logo=alpine-linux&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![ActiveMQ](https://img.shields.io/badge/active-mq-%23B7178C.svg?style=for-the-badge&logo=activemq&logoColor=white)
![KeepAlived](https://img.shields.io/badge/-Keepalived-%23870000?style=for-the-badge&logo=keepalived&logoColor=white)
![Postgres](https://img.shields.io/badge/postgres-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white)
![RTPProxy](https://img.shields.io/badge/-RTPPROXY%20-4285F4?style=for-the-badge&logo=RTPProxy&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=Prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/grafana-%23F46800.svg?style=for-the-badge&logo=grafana&logoColor=white)
![Alertmanager](https://img.shields.io/badge/Alertmanager-CB2029?style=for-the-badge&logo=Prometheus&logoColor=white)
![Karma](https://img.shields.io/badge/-Karma-%23Clojure?style=for-the-badge&logo=Karma&logoColor=white)
![Traefik](https://img.shields.io/badge/Traefik-18BFFF?style=for-the-badge&logo=Traefik&logoColor=white)
![Apache Kafka](https://img.shields.io/badge/Apache%20Kafka-000?style=for-the-badge&logo=apachekafka)

![reposize](https://img.shields.io/github/repo-size/mach1el/docker-library)
![commits-activites](https://img.shields.io/github/commit-activity/m/mach1el/docker-library)

This repository houses a collection of custom Docker images.  These images are built and published to Docker Hub, providing ready-to-use solutions for various needs.

## About

This repository serves as the central location for managing and building all custom Docker images used in my projects.  It streamlines the process of creating, updating, and publishing these images.

## Repository Structure

The repository is organized by service, with each service having its own directory.  Within each service directory, you'll find:

* **`Dockerfile`:** The Dockerfile used to build the image.  Multiple versions of a service might have separate Dockerfiles (e.g., `activemq/5.18.x/Dockerfile`, `activemq/6.1.x/Dockerfile`).
* **`README.md`:** A service-specific README with instructions on how to use the image.
* **`units/`:** Contains configuration files and service scripts used within the container.  Often, you'll find a `units/etc/service/<service_name>/run` script for starting the service.
* **Other files:**  May include configuration files (e.g., `*.yml`, `*.conf`), scripts (`*.sh`), or other resources required by the Docker image.

## Available Images

The following Docker images are available:

* **`debian` ([https://hub.docker.com/r/mich43l/debian](https://hub.docker.com/r/mich43l/debian))::** This image provides a minimal Debian Bookworm base for other Docker images. It's designed to be lightweight and secure, offering a stable foundation for building custom applications.  It includes essential utilities and tools commonly needed in a Debian environment.
* **`alpine` ([https://hub.docker.com/r/mich43l/alpine](https://hub.docker.com/r/mich43l/alpine)):** This image provides a minimal Alpine Linux base. Alpine Linux is known for its small size and security focus, making it ideal for creating very efficient Docker images.

## Building and Publishing Images

```bash
#!/bin/bash

IMAGE_NAME=$1  # e.g., debian
VERSION=$2     # e.g., latest, 1.0.0

docker build -t mich43l/$IMAGE_NAME:$VERSION images/$IMAGE_NAME
docker push mich43l/$IMAGE_NAME:$VERSION
```

## Usage
General instructions on how to use the images.  Point users to the individual service READMEs for specific instructions.

## Contributing
Guidelines for contributing to the repository.

# Docker hub
[![Static Badge](https://img.shields.io/badge/dockerhub-mich43l-orange?style=flat-square)](https://hub.docker.com/u/mich43l)

# License
![license](https://img.shields.io/github/license/mach1el/docker-library?color=red)