# Docker Opensips

![Debian](https://img.shields.io/badge/Debian-D70A53?style=for-the-badge&logo=debian&logoColor=white)
![OpenSips](https://img.shields.io/badge/OpenSips-3DDC84?style=for-the-badge&logo=opensips&logoColor=white)
![imgsize](https://img.shields.io/docker/image-size/mich43l/opensips/latest?color=red&style=flat-square)
![dockerautomated](https://img.shields.io/docker/automated/mich43l/opensips?style=flat-square)

Opensips - SIP proxy/server on docker. See also [RTPProxy](../rtpproxy/). OpenSIPS and RTPproxy are commonly used together in SIP (Session Initiation Protocol) based VoIP (Voice over IP) systems. OpenSIPS is a robust SIP server, while RTPproxy handles media relay (RTP streams) for NAT traversal and other scenarios. In this image it also included the [Opensips Control Panel](https://controlpanel.opensips.org/) run with apache2 at port 80

## Run

```bash
docker run -tid --name=opensips \
  --network=host \
  -v $(pwd)/path/to/opensips.cfg:/etc/opensips/opensips.cfg \
  mich43l/opensips
```

```bash
docker run -tid --name=rtpproxy \
  --network=host \
  -v /var/lib/rtpproxy-recording:/var/lib/rtpproxy-recording \
  -v /var/spool/rtpproxy:/var/spool/rtpproxy mich43l/rtpproxy
```
> Run with RTPproxy

## Variables

| Environment Variable    | Default    | Description                                                        |
|:------------------------|:-----------|:-------------------------------------------------------------------|
| OPENSIPS_CP_DB_DRIVER   | psql       | Set data driver for OpenSips control panel. Default: `psql`        |
| OPENSIPS_CP_DB_HOST     | localhost  | Set database host that Opensips connected to. Default: `localhost` |
| OPENSIPS_CP_DB_PORT     | 5432       | Set port of the database. Default: `5432`                          |
| OPENSIPS_CP_DB_USER     | opensips   | Set database user. Default: `opensips`                             |
| OPENSIPS_CP_DB_PASSWORD | opensipsrw | Set database password. Default: `opensipsrw`                       |
| OPENSIPS_CP_DB_NAME     | opensips   | Select database name. Default: `opensips`                          |