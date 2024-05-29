FROM debian:bullseye

LABEL architecture="x86_64"             \
  build-date="$BUILD_DATE"              \
  license="MIT"                         \
  name="mich43l/postgresql"             \
  summary="Postgresql containerization" \
  vcs-type="git"                        \
  vcs-url="https://github.com/mach1el/docker-library"

ARG CC=en_US
ARG ENCODING=UTF-8
ARG LANG=en_US.UTF-8
ARG GOSU_VERSION=1.17
ARG PGSQL_VERSION=15

ENV CC $CC
ENV ENCODING $ENCODING
ENV LANG $LANG
ENV DEBIAN_VERSION bullseye
ENV GOSU_VERSION $GOSU_VERSION
ENV PGSQL_VERSION $PGSQL_VERSION
ENV PATH $PATH:/usr/lib/postgresql/${PGSQL_VERSION}/bin
ENV PGDATA /var/lib/postgresql/data

RUN set -eux; \
  groupadd -r postgres --gid=999; \
  useradd -r -g postgres --uid=999 --home-dir=/var/lib/postgresql --shell=/bin/bash postgres; \
  mkdir -p /var/lib/postgresql; \
  chown -R postgres:postgres /var/lib/postgresql

RUN apt-get update \
  && apt-get -yqq install \
  ca-certificates \
  gnupg2 \
  libnss-wrapper \
  xz-utils \
  wget \
  dirmngr \
  perl \
  pwgen \
  openssl \
  && rm -rf /var/lib/apt/lists/*

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

RUN set -eux; \
  if [ -f /etc/dpkg/dpkg.cfg.d/docker ]; then \
    grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
    sed -ri '/\/usr\/share\/locale/d' /etc/dpkg/dpkg.cfg.d/docker; \
    ! grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
  fi; \
  apt-get update; apt-get install -y locales; rm -rf /var/lib/apt/lists/*; \
  localedef -i ${CC} -c -f ${ENCODING} -A /usr/share/locale/locale.alias ${LANG}

RUN mkdir /docker-entrypoint-initdb.d

RUN wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O- | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ ${DEBIAN_VERSION}-pgdg main" | tee /etc/apt/sources.list.d/postgresql.list
RUN apt-get update && apt-get install -yqq postgresql-${PGSQL_VERSION} && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
  dpkg-divert --add --rename --divert "/usr/share/postgresql/postgresql.conf.sample.dpkg" "/usr/share/postgresql/${PGSQL_VERSION}/postgresql.conf.sample"; \
  cp -v /usr/share/postgresql/postgresql.conf.sample.dpkg /usr/share/postgresql/postgresql.conf.sample; \
  ln -sv ../postgresql.conf.sample "/usr/share/postgresql/${PGSQL_VERSION}/"; \
  sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/share/postgresql/postgresql.conf.sample; \
  grep -F "listen_addresses = '*'" /usr/share/postgresql/postgresql.conf.sample

RUN mkdir -p /var/run/postgresql \
  && chown -R postgres:postgres /var/run/postgresql \
  && chmod 2777 /var/run/postgresql

RUN mkdir -p "$PGDATA" \
  && chown -R postgres:postgres "$PGDATA" \
  && chmod 777 "$PGDATA"

VOLUME /var/lib/postgresql/data

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh

EXPOSE 5432
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["postgres"]