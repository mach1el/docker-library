ARG VERSION=latest

FROM alpine:${VERSION}

LABEL architecture="x86_64"                 \
      build-date="$BUILD_DATE"              \
      license="MIT"                         \
      name="mich43l/os:alpine"              \
      summary="Alpine on container x runit" \
      vcs-type="git"                        \
      vcs-url="https://github.com/mach1el/docker-library"

ARG GOSU_VERSION=1.17

ENV GOSU_VERSION=$GOSU_VERSION \
  USERNAME=mich43l \
  USER_UID=1000 \
  USER_GID=$USER_UID \
  USER_HOME=/home/mich43l

RUN set -eux; \
  addgroup -S -g $USER_GID $USERNAME && \
  adduser -S -D -u $USER_UID -s /bin/sh -h $USER_HOME -G $USERNAME $USERNAME

RUN set -eux; \
  apk add --no-cache \
  bash \
  busybox-extras \
  ca-certificates \
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
  gcompat \
  libc6-compat \
  gzip \
  zsh \
  unzip \
  && rm -rf /var/cache/apk/*

RUN set -x; \
  dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
  wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
  wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
  export GNUPGHOME="$(mktemp -d)"; \
  gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
  gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
  command -v gpgconf && gpgconf --kill all || :; \
  rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
  chmod +x /usr/local/bin/gosu; \
  gosu --version; \
  gosu nobody true

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN sed -i "s|ZSH_THEME=\"robbyrussell\"|ZSH_THEME=\"agnoster\"|g" ~/.zshrc

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

CMD ["/bin/zsh"]
ENTRYPOINT [ "/docker-entrypoint.sh" ]