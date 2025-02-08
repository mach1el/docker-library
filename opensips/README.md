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