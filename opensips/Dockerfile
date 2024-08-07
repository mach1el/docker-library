FROM mich43l/os:debian

ARG OPENSIPS_VERSION=3.4

ENV OPENSIPS_CFG=/etc/opensips/opensips.cfg
ENV APACHE_LOG_DIR=/var/log/apache2
ENV APACHE_RUN_DIR=/var/run/apache2
ENV APACHE_PID_FILE=/var/run/apache2/apache2.pid
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data

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
    apache2 \
    libapache2-mod-php \
    php-curl \
    php \
    php-mysql \
    php-gd \
    php-pear \
    php-cli \
    php-apcu \
    php-pgsql \
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


RUN git clone --branch=9.3.4 https://github.com/OpenSIPS/opensips-cp.git /var/www/html/opensips-cp
RUN chown -R www-data:www-data /var/www/html/opensips-cp/

COPY units/etc/apache2/apache2.conf /etc/apache2
COPY units/etc/apache2/sites-available /etc/apache2/sites-available

RUN rm -rf /etc/apache2/sites-available/default-ssl.conf

RUN a2dissite 000-default.conf
RUN a2ensite opensips-cp.conf
RUN a2dismod ssl

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

VOLUME ["/etc/opensips"]
VOLUME ["/etc/apache2/"]
VOLUME ["/var/www/html/opensips-cp"]
VOLUME ["/tmp"]

EXPOSE 80/tcp
EXPOSE 5060/udp

ADD units/etc/service /etc/service
ADD units/etc/opensips /etc/opensips

RUN chmod +x /etc/service/apache2/run
RUN chmod +x /etc/service/opensips/run