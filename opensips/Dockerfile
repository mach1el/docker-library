FROM mich43l/debian:bookworm

ARG OPENSIPS_VERSION=3.4 \
  OPENSIPS_CLI=true

ENV OPENSIPS_CFG=/etc/opensips/opensips.cfg

RUN apt-get update -qq && \
  apt-get install -y --no-install-recommends \
  python3-pip \
  libpq-dev \
  sudo \
  pkg-config \
  file \
  build-essential \
  libbcg729-0 \
  libsndfile1 \
  libsystemd-dev \
  && rm -rf /var/lib/apt/lists

RUN curl https://apt.opensips.org/opensips-org.gpg -o /usr/share/keyrings/opensips-org.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/opensips-org.gpg] https://apt.opensips.org bookworm ${OPENSIPS_VERSION}-releases" >/etc/apt/sources.list.d/opensips.list
RUN echo "deb [signed-by=/usr/share/keyrings/opensips-org.gpg] https://apt.opensips.org bookworm cli-nightly" >/etc/apt/sources.list.d/opensips-cli.list

RUN apt-get update -qq && \
  apt-get install -yqq \
  net-tools \
  sngrep \
  opensips                     \
  opensips-berkeley-module     \
  opensips-carrierroute-module \
  opensips-cgrates-module      \
  opensips-cli                 \
  opensips-compression-module  \
  opensips-cpl-module          \
  opensips-dbhttp-module       \
  opensips-dialplan-module     \
  opensips-emergency-module    \
  opensips-geoip-module        \
  opensips-http-modules        \
  opensips-identity-module     \
  opensips-jabber-module       \
  opensips-json-module         \
  opensips-ldap-modules        \
  opensips-lua-module          \
  opensips-memcached-module    \
  opensips-mongodb-module      \
  opensips-mysql-module        \
  opensips-perl-modules        \
  opensips-postgres-module     \
  opensips-presence-modules    \
  opensips-rabbitmq-modules    \
  opensips-radius-modules      \
  opensips-redis-module        \
  opensips-regex-module        \
  opensips-restclient-module   \
  opensips-sctp-module         \
  opensips-siprec-module       \
  opensips-snmpstats-module    \
  opensips-sqlite-module       \
  opensips-stir-shaken-module  \
  opensips-tls-module          \
  opensips-tls-openssl-module  \
  opensips-tlsmgm-module       \
  opensips-unixodbc-module     \
  opensips-uuid-module         \
  opensips-wss-module          \
  opensips-xmlrpc-module       \
  opensips-xmpp-module         \
  opensips-prometheus-module   \
  opensips-python-module       \
  && rm -rf /var/lib/apt/lists/*

RUN if [ ${OPENSIPS_CLI} = true ]; then \
  echo "deb https://apt.opensips.org bookworm cli-nightly" >/etc/apt/sources.list.d/opensips-cli.list \
  && apt-get -y update -qq && apt-get -y install opensips-cli \
  ;fi

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

VOLUME ["/tmp"]
EXPOSE 5060/udp

ADD units/etc/opensips /etc/opensips
ADD units/etc/service/opensips /etc/service/opensips

RUN chmod +x /etc/service/opensips/run