# PostgreSQL Docker Image

![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Postgres](https://img.shields.io/badge/postgres-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white)
![imgsize](https://img.shields.io/docker/image-size/mich43l/postgresql/latest?color=orange)
![dockerautomated](https://img.shields.io/docker/automated/mich43l/postgresql)

This repository contains the Dockerfile and resources to build a lightweight and efficient PostgreSQL container based on the latest Debian image. The container is designed to run PostgreSQL securely and flexibly, providing a robust foundation for database-driven applications.

## Features

- **PostgreSQL Version**: Configurable via build argument (`PGSQL_VERSION`), defaults to `17`.
- **Lightweight Base**: Built on the latest Debian base image for stability and security.
- **Locale Support**: Supports configurable locale settings (`LANG`, `CC`, and `ENCODING`).
- **Custom Entrypoint**: Includes a customizable `docker-entrypoint.sh` script for initialization.
- **Enhanced Security**: Utilizes `gosu` to manage privilege escalation.
- **Persistent Data**: Data volume mounted at `/var/lib/postgresql/data` for data persistence.
- **Dynamic Configuration**: Configured to accept external connections by default (`listen_addresses = '*'`).
- **Custom Initialization**: Supports initialization scripts via `/docker-entrypoint-initdb.d`.

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
 
| Variables              | Default       | Description                                                  |
|:---------------------- |:--------------|:-------------------------------------------------------------|
| CC                     | `en_US`       | Specifies the input source file for locale definitions.      |
| LANG                   | `en_US.UTF-8` | Specifies the name of the locale to generate.                |
| ENCODING               | `UTF-8`       | Specifies the character encoding file to use for the locale. |
| POSTGRES_DB            | `postgre`     | Specify name for database.                                   |
| POSTGRES_USER          | `postgre`     | Use other username instead of postgres.                      |
| POSTGRES_PASSWORD      | `postgre`     | Change default postgres password.                            |
| POSTGRES_LOG_STATEMENT | `all`         | Specify postgres log statment mode.                          |

## Run

```bash
docker run -d \
  --name postgresql \
  -e POSTGRES_USER=youruser \
  -e POSTGRES_PASSWORD=yourpassword \
  -e POSTGRES_DB=yourdatabase \
  -v /path/to/data:/var/lib/postgresql/data \
  -p 5432:5432 \
  mich43l/postgresql
```