FROM debian:latest

LABEL architecture="x86_64"             \
  build-date="$BUILD_DATE"              \
  license="MIT"                         \
  name="mich43l/postgresql"             \
  summary="Postgresql containerization" \
  vcs-type="git"                        \
  vcs-url="https://github.com/mach1el/docker-library"

ARG PGSQL_VERSION=17 \
  GOSU_VERSION=1.17
ARG CC=en_US \
  ENCODING=UTF-8 \
  LANG=en_US.UTF-8

ENV CC=$CC \
  ENCODING=$ENCODING \
  LANG=$LANG \
  PGSQL_VERSION=$PGSQL_VERSION \
  PATH=$PATH:/usr/lib/postgresql/${PGSQL_VERSION}/bin \
  PGDATA=/var/lib/postgresql/data

RUN set -eux; \
  groupadd -r postgres --gid=990; \
  useradd -r -g postgres --uid=990 --home-dir=/var/lib/postgresql --shell=/bin/bash postgres; \
  mkdir -p /var/lib/postgresql; \
  chown -R postgres:postgres /var/lib/postgresql

RUN apt update \
  && apt -yqq install \
  ca-certificates \
  curl \
  wget \
  gnupg2 \
  libnss-wrapper \
  xz-utils \
  wget \
  dirmngr \
  perl \
  pwgen \
  openssl \
  lsb-release \
  locales \
  && rm -rf /var/lib/apt/lists/*

RUN set -x \
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
  localedef -i ${CC} -c -f ${ENCODING} -A /usr/share/locale/locale.alias ${LANG}

RUN mkdir /docker-entrypoint-initdb.d

RUN install -d /usr/share/postgresql-common/pgdg; \
  curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc; \
  echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt update && apt install -yqq postgresql-${PGSQL_VERSION} && rm -rf /var/lib/apt/lists/*

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

ADD ./docker-entrypoint-initdb.d /docker-entrypoint-initdb.d

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh

EXPOSE 5432
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["postgres"]