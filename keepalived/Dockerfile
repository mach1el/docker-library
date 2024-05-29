FROM mich43l/os:alpine

LABEL architecture="x86_64"                       \
      build-date="$BUILD_DATE"                    \
      license="MIT"                               \
      name="mich43l/keepalived"                   \
      summary="debian based keepalived container" \
      vcs-type="git"                              \
      vcs-url="https://github.com/mach1el/docker-keepalived"

RUN apk add --no-cache \
    keepalived     \
    ipvsadm        \
    iproute2       \
    net-tools      \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/keepalived

ADD units /
RUN chmod +x /etc/service/*/*

ENTRYPOINT [ "/docker-entrypoint.sh" ]