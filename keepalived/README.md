# Docker keepalived
![Alpine Linux](https://img.shields.io/badge/Alpine_Linux-%230D597F.svg?style=for-the-badge&logo=alpine-linux&logoColor=white)
![KeepAlived](https://img.shields.io/badge/-Keepalived-%23870000?style=for-the-badge&logo=keepalived&logoColor=white)
![imgsize](https://img.shields.io/docker/image-size/mich43l/keepalived/latest?color=red&style=flat-square)
![dockerautomated](https://img.shields.io/docker/automated/mich43l/keepalived?style=flat-square)

Keepalived on docker, keep systems high availbility and readility

## Prerequisites
In order for this example to work, you need to enable binding to a non-local IP address. On each node run to enable this setting:

```
 $ echo 1 > /proc/sys/net/ipv4/ip_nonlocal_bind
```
To permanently save this setting, add the following line to a file like **/etc/sysctl.d/99-non-local-bind.conf**

```
net.ipv4.ip_nonlocal_bind = 1
```

## Master Node
```
docker run -tid \
--net=host \
--name=keepalived \
--restart=always \
--cap-add NET_ADMIN \
-e KEEPALIVED_AUTOCONF=true \
-e KEEPALIVED_STATE=MASTER \
-e KEEPALIVED_INTERFACE=eth0 \
-e KEEPALIVED_VIRTUAL_ROUTER_ID=51 \
-e KEEPALIVED_UNICAST_SRC_IP=10.10.0.21 \
-e KEEPALIVED_UNICAST_PEER_0=10.10.0.22 \
-e KEEPALIVED_TRACK_INTERFACE=eth0 \
-e KEEPALIVED_VIRTUAL_IPADDRESS_1="10.10.0.253/24 dev eth0" \
mich43l/keepalived
```
## Backup Node
```
docker run -tid \
--net=host \
--name=keepalived \
--restart=always \
--cap-add NET_ADMIN \
-e KEEPALIVED_AUTOCONF=true \
-e KEEPALIVED_STATE=BACKUP \
-e KEEPALIVED_INTERFACE=eth0 \
-e KEEPALIVED_VIRTUAL_ROUTER_ID=51 \
-e KEEPALIVED_UNICAST_SRC_IP=10.10.0.22 \
-e KEEPALIVED_UNICAST_PEER_0=10.10.0.21 \
-e KEEPALIVED_TRACK_INTERFACE=eth0 \
-e KEEPALIVED_VIRTUAL_IPADDRESS_1="10.10.0.253/24 dev eth0" \
mich43l/keepalived
```