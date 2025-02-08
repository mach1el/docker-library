# Operating System container images
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Alpine Linux](https://img.shields.io/badge/Alpine_Linux-%230D597F.svg?style=for-the-badge&logo=alpine-linux&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-D70A53?style=for-the-badge&logo=debian&logoColor=white)

# Alpine on Container with Runit

## Overview
This repository provides a lightweight Alpine-based container image with additional utilities and tools pre-installed. It uses `runit` as the init system and includes a number of useful packages.

## Features
- Based on Alpine Linux
- `runit` as init system
- Essential utilities including:
  - `bash`, `vim`, `curl`, `git`
  - `python3`, `dpkg`, `gnupg`, `procps`
  - `parallel`, `tzdata`, `gcompat`, `gzip`, `zsh`
  - `unzip`, `ca-certificates`
- `gosu` installed for better process control
- `oh-my-zsh` with `agnoster` theme enabled
- Non-root user `mich43l` created for better security
- Custom entrypoint script

## Usage
### Build the Image
```sh
 docker build --build-arg VERSION=latest -t mich43l/os:alpine .
```

### Run the Container
```sh
 docker run -it mich43l/os:alpine
```

### Customizing the Image
You can override the default user by providing build arguments:
```sh
 docker build --build-arg USERNAME=myuser --build-arg USER_UID=2000 --build-arg USER_GID=2000 -t myimage .
```

### EntryPoint Script
The container uses a custom `docker-entrypoint.sh` script, which ensures proper setup before launching the shell.

---

# Debian on Container with Runit

## Overview
This repository provides a lightweight Debian-based container image with additional utilities and tools pre-installed. It uses `runit` as the init system and includes a number of useful packages.

## Features
- Based on Debian Linux
- `runit` as init system
- Essential utilities including:
  - `bash`, `vim`, `curl`, `git`
  - `python3`, `dpkg`, `gnupg`, `procps`
  - `parallel`, `tzdata`, `gzip`, `zsh`, `net-tools`
  - `unzip`, `ca-certificates`, `locales`, `locales-all`
- `gosu` installed for better process control
- `oh-my-zsh` with `agnoster` theme enabled
- Non-root user `mich43l` created for better security
- Custom entrypoint script

## Usage
### Build the Image
```sh
 docker build --build-arg VERSION=latest -t mich43l/os:debian .
```

### Run the Container
```sh
 docker run -it mich43l/os:debian
```

### Customizing the Image
You can override the default user by providing build arguments:
```sh
 docker build --build-arg USERNAME=myuser --build-arg USER_UID=2000 --build-arg USER_GID=2000 -t myimage .
```

### EntryPoint Script
The container uses a custom `docker-entrypoint.sh` script, which ensures proper setup before launching the shell.

---

## License
This project is licensed under the MIT License.

## Repository
[GitHub Repository](https://github.com/mach1el/docker-library)

## Author
Maintained by `mich43l`