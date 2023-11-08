# Postgresql on docker
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Postgres](https://img.shields.io/badge/postgres-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white)
![imgsize](https://img.shields.io/docker/image-size/mich43l/postgresql/latest?color=orange)
![dockerautomated](https://img.shields.io/docker/automated/mich43l/postgresql)

## Build image
```
git clone https://github.com/mach1el/docker-library.git && \
  cd docker-library/postgresql && \
  docker buildx build --platform linux/amd64 build -t postgresql .
```

```
docker buildx build --platform linux/amd64 --build-arg PGSQL_VERSION=14 -t postgresql:14 .
```
> `Build with arguments`

## Run
* docker run -tid --rm -p5432 -e POSTGRES_LOG_STATEMENT=all mich43l/postgresql
* docker run --name my-postgres -p 5432:5432 -e POSTGRES_PASSWORD=mysecretpassword -d mich43l/postgresql
* docker run -tid --rm -p 5432 \
    -e POSTGRES_PASSWORD=mysecretpassword \
    -e POSTGRES_USER=someuser mich43l/postgresql
* docker run --name my-postgres \
    -e POSTGRES_PASSWORD=mysecretpassword -d \
    -v /path/somewhere/:/var/lib/postgresql/data/ mich43l/postgresql

## Build arguments
|     ARG       |               VALUE                              |
|:-------------:|:------------------------------------------------:|
| CC            | Country code. Default: `en_US`                   |
| ENCODING      | Select encoding. Default: `UTF-8`                |
| LANG          | Set locate language. Default `en_US.UTF-8`       |
| GOSU_VERSION  | Choose gosu version to install. Default: `1.16`  |
| PGSQL_VERSION | Choose Postgres version to install. Default: `15`|


## Environment variables
|     Param              |               Exaplain                 |
|:----------------------:|:--------------------------------------:|
| POSTGRES_DB            | Specify name for database              |
| POSTGRES_USER          | Use other username instead of postgres |
| POSTGRES_PASSWORD      | Change default postgres password       |
| POSTGRES_LOG_STATEMENT | Specify postgres log statment mode     |