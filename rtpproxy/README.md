# RTPproxy on docker
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![RTPProxy](https://img.shields.io/badge/-RTPPROXY%20-4285F4?style=for-the-badge&logo=RTPProxy&logoColor=white)
![imgsize](https://img.shields.io/docker/image-size/mich43l/rtpproxy?color=purple&style=flat-square)

RTPproxy server for streaming RTP on SIP proxy/server such as: [Opensips](https://www.opensips.org/),[Kamailio](https://www.kamailio.org/w/)
	
## Run
*	*docker run -tid --name=rtpproxy --network=host mich43l/rtpproxy*
* *docker run -tid --name=rtpproxy --network=host -v /var/lib/rtpproxy-recording:/var/lib/rtpproxy-recording -v /var/spool/rtpproxy:/var/spool/rtpproxy mich43l/rtpproxy*
* *docker run -tid --name=rtpproxy --network=host -e RTPPROXY_LISTEN_HOST="192.168.0.1" -e RTPRPOXY_NOFILE_LIMIT="65535" -e RTPPROXY_LOG_LEVEL="INFO:LOG_LOCAL5" mich43l/rtpproxy*

## Build arguments
|     ARG       |               VALUE                              |
|:-------------:|:------------------------------------------------:|
| GOSU_VERSION  | Choose gosu version to install. Default: `1.16`  |


## Environment variables
|     Param             |               Exaplain                                                         |
|:---------------------:|:------------------------------------------------------------------------------:|
| RTPPROXY_LISTEN_HOST  | Set RTPPROXY host to listenon. Default: `0.0.0.0`                              |
| RTPPROXY_CTRL_SOCKET  | Use other username instead of postgres. Default: `udp:*:7890`                  |
| RTPRPOXY_NOFILE_LIMIT | Set the maximum number of open file descriptors per process. Default: `500000` |
| RTPPROXY_MIN_PORT     | Set lower limit on UDP ports range. Default: `10000`                           |
| RTPPROXY_MAX_PORT     | Set upper limit on UDP ports range. Default: `65000``                          |
| RTPPROXY_LOG_LEVEL    | Configures the verbosity level of the log output. Default: `INFO:LOG_LOCAL5`   |
| RTPPROXY_PARAM        | Filfull rtpproxy parameters                                                    |