FROM mich43l/os:alpine

LABEL architecture="x86_64"                        \
      build-date="$BUILD_DATE"                     \
      license="MIT"                                \
      name="mich43l/activemq"                      \
      summary="Activemq x Alpine containerization" \
      vcs-type="git"                               \
      vcs-url="https://github.com/mach1el/docker-library"

ARG VERSION=5.18.4
ARG JAVA_VERSION=11.0.23.9.1

RUN wget -O /THIRD-PARTY-LICENSES-20200824.tar.gz https://corretto.aws/downloads/resources/licenses/alpine/THIRD-PARTY-LICENSES-20200824.tar.gz && \
    echo "82f3e50e71b2aee21321b2b33de372feed5befad6ef2196ddec92311bc09becb  /THIRD-PARTY-LICENSES-20200824.tar.gz" | sha256sum -c - && \
    tar x -ovzf THIRD-PARTY-LICENSES-20200824.tar.gz && \
    rm -rf THIRD-PARTY-LICENSES-20200824.tar.gz && \
    wget -O /etc/apk/keys/amazoncorretto.rsa.pub https://apk.corretto.aws/amazoncorretto.rsa.pub && \
    SHA_SUM="6cfdf08be09f32ca298e2d5bd4a359ee2b275765c09b56d514624bf831eafb91" && \
    echo "${SHA_SUM}  /etc/apk/keys/amazoncorretto.rsa.pub" | sha256sum -c - && \
    echo "https://apk.corretto.aws" >> /etc/apk/repositories && \
    apk add --no-cache amazon-corretto-11=${JAVA_VERSION}-r0 && \
    rm -rf /usr/lib/jvm/java-11-amazon-corretto/lib/src.zip

ENV LANG=C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/default-jvm
ENV PATH=$PATH:/usr/lib/jvm/default-jvm/bin

ENV ACTIVEMQ_VERSION=$VERSION
ENV ACTIVEMQ=apache-activemq-$ACTIVEMQ_VERSION
ENV ACTIVEMQ_HOME=/opt/activemq

RUN apk add net-tools --no-cache && rm -rf /var/cache/apk/*

RUN wget -O $ACTIVEMQ-bin.tar.gz https://archive.apache.org/dist/activemq/${ACTIVEMQ_VERSION}/${ACTIVEMQ}-bin.tar.gz && \
    tar -xvzf $ACTIVEMQ-bin.tar.gz && \
    rm -f $ACTIVEMQ-bin.tar.gz && \
    mv $ACTIVEMQ $ACTIVEMQ_HOME && \
    chown -R mich43l:mich43l $ACTIVEMQ_HOME && \
    chown -h mich43l:mich43l $ACTIVEMQ_HOME 

ADD units /
RUN chmod +x /etc/service/*/*

EXPOSE 61616
EXPOSE 5672
EXPOSE 61613
EXPOSE 8161

WORKDIR $ACTIVEMQ_HOME