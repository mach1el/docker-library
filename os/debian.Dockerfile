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

ENV DEBIAN_FRONTEND noninteractive

ENV GOSU_VERSION    $GOSU_VERSION
ENV USERNAME        mich43l
ENV USER_UID        1000
ENV USER_GID        $USER_UID
ENV USER_HOME       /home/mich43l

RUN set -eux; \
  groupadd -r mich43l --gid=$USER_GID; \
  useradd -r -g mich43l --uid=$USER_UID --home-dir=/home/mich43l --shell=/bin/bash mich43l; \
  mkdir -p /home/mich43l; \
  chown -R mich43l:mich43l /home/mich43l

RUN apt-get update \
  && apt-get -yqq install \
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

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# RUN sed -i "s|ZSH_THEME=\"robbyrussell\"|ZSH_THEME=\"agnoster\"|g" ~/.zshrc

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

CMD ["/bin/zsh"]
ENTRYPOINT [ "/docker-entrypoint.sh" ]
