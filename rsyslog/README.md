# Docker rsyslog
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Rsyslog](https://img.shields.io/badge/rsyslog-000000?style=for-the-badge&logo=rsyslog&logoColor=white)
![imgsize](https://img.shields.io/docker/image-size/mich43l/rsyslog/latest?color=red&style=flat)

Persistent logging on Docker container
 
## Building image
```
git clone https://github.com/mach1el/docker-library.git \
  cd docker-library/rsyslog && \
  docker buildx build --platform linux/amd64 -t rsyslog .
``` 

## Run from hub
- ***docker run --name rsyslog --cap-add SYSLOG --restart always -v /var/log:/var/log -p 514:514 -p 514:514/udp  mich43l/rsyslog***
- ***docker run --name rsyslog --cap-add SYSLOG --restart always -v /var/log:/path/to/log -p 514:514 -p 514:514/udp  mich43l/rsyslog***
- ***docker run --log-driver syslog --log-opt syslog-address=tcp://[syslog_ip]:514 alpine***

## Explain

| Param                 | Meaning                                                       |
| :-------------------: | :-----------------------------------------------------------: |
| --cap-add SYSLOG      | Allow container to perform privileged syslog(2)               |
| --restart always      | Restart container regardless of the exit status               |
| -v /var/log:/var/log  | Mount host /var/log directory in container /var/log directory |
| -p 514:514            | Bind Host TCP 514 port to contaainer TCP 514 port             |
| -p 514:514/udp        | Bind Host UDP 514 port to contaainer UDP 514 port             |