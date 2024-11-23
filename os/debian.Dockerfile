ARG VERSION=latest

FROM debian:${VERSION}

LABEL architecture="x86_64"                 \
      build-date="$BUILD_DATE"              \
      license="MIT"                         \
      name="mich43l/os:debian"              \
      summary="Debian on container x runit" \
      vcs-type="git"                        \
      vcs-url="https://github.com/mach1el/docker-library"

ARG GOSU_VERSION=1.17

ENV DEBIAN_FRONTEND=noninteractive \
  GOSU_VERSION=${GOSU_VERSION} \
  USERNAME=mich43l \
  USER_UID=1000 \
  USER_GID=1000 \
  USER_HOME=/home/mich43l

RUN set -eux; \
  groupadd -r ${USERNAME} --gid=${USER_GID}; \
  useradd -r -g ${USERNAME} --uid=${USER_UID} --home-dir=${USER_HOME} --shell=/bin/zsh ${USERNAME}; \
  mkdir -p ${USER_HOME}; \
  chown -R ${USERNAME}:${USERNAME} ${USER_HOME}

RUN apt-get update \
  && apt-get -yqq install --no-install-recommends \
  ca-certificates \
  gnupg2 \
  xz-utils \
  git \
  curl \
  vim \
  dpkg \
  python3 \
  gnupg \
  procps \
  runit \
  parallel \
  tzdata \
  gzip \
  zsh \
  unzip \
  net-tools \
  locales \
  locales-all \
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

RUN set -x \
  && update-locale \
  && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
  && sed -i "s|ZSH_THEME=\"robbyrussell\"|ZSH_THEME=\"agnoster\"|g" ~/.zshrc

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

CMD ["/bin/zsh"]
ENTRYPOINT [ "/docker-entrypoint.sh" ]
