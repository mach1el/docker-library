FROM ubuntu:20.04

LABEL architecture="x86_64"                               \
      build-date="$BUILD_DATE"                            \
      license="MIT"                                       \
      name="mich43l/rtpproxy"                             \
      summary="debian based rtpproxy container"           \
      vcs-type="git"                                      \
      vcs-url="https://github.com/mach1el/docker-library"

ARG GOSU_VERSION=1.16

ENV GOSU_VERSION $GOSU_VERSION
ENV RTPPROXY_BIN /usr/bin/rtpproxy

RUN set -eux; \
  groupadd -r rtpproxy --gid=1000; \
  useradd -r -g rtpproxy --uid=1000 --home-dir=/home/rtpproxy --shell=/bin/bash rtpproxy; \
  mkdir -p /home/rtpproxy; \
  chown -R rtpproxy:rtpproxy /home/rtpproxy

RUN apt-get update \
  && apt-get -y install \
  dirmngr \
  runit \
  procps \
  parallel \
  rtpproxy \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN set -x \
  && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
  && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
  && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true

RUN mkdir -p /var/lib/rtpproxy-recording
RUN mkdir -p /var/spool/rtpproxy

COPY ./units/etc/service/rtpproxy/run /etc/service/rtpproxy/run
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /etc/service/*/*
RUN chmod +x /docker-entrypoint.sh

VOLUME /var/spool/rtpproxy
VOLUME /var/lib/rtpproxy-recording

EXPOSE 7890/udp

ENTRYPOINT ["/docker-entrypoint.sh"]