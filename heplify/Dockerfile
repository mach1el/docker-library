FROM debian:bullseye-slim

LABEL architecture="x86_64"                             \
      build-date="$BUILD_DATE"                          \
      license="MIT"                                     \
      name="mich43l/hep-cli"                            \
      summary="debian based heplify client container"   \
      vcs-type="git"                                    \
      vcs-url="https://github.com/mach1el/docker-library"

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=Asia/Ho_Chi_Minh

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gnupg2 \
    dirmngr \
    runit   \
    procps  \
    parallel \
    sudo \
    && rm -rf /var/lib/apt/lists

RUN curl -s https://packagecloud.io/install/repositories/qxip/sipcapture/script.deb.sh | bash
RUN apt-get install heplify && rm -rf /var/lib/apt/lists

# RUN mkdir -p /etc/service/heplify

COPY ./units/etc/service/heplify/run /etc/service/heplify/run
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /etc/service/*/*
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]