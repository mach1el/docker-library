FROM mich43l/os:alpine

ARG version=17.0.11.9.1
ARG kafka_version=3.0.0
ARG scala_version=2.13

RUN apk add bash tzdata --no-cache

RUN wget -O /THIRD-PARTY-LICENSES-20200824.tar.gz https://corretto.aws/downloads/resources/licenses/alpine/THIRD-PARTY-LICENSES-20200824.tar.gz && \
  echo "82f3e50e71b2aee21321b2b33de372feed5befad6ef2196ddec92311bc09becb  /THIRD-PARTY-LICENSES-20200824.tar.gz" | sha256sum -c - && \
  tar x -ovzf THIRD-PARTY-LICENSES-20200824.tar.gz && \
  rm -rf THIRD-PARTY-LICENSES-20200824.tar.gz && \
  wget -O /etc/apk/keys/amazoncorretto.rsa.pub https://apk.corretto.aws/amazoncorretto.rsa.pub && \
  SHA_SUM="6cfdf08be09f32ca298e2d5bd4a359ee2b275765c09b56d514624bf831eafb91" && \
  echo "${SHA_SUM}  /etc/apk/keys/amazoncorretto.rsa.pub" | sha256sum -c - && \
  echo "https://apk.corretto.aws" >> /etc/apk/repositories && \
  apk add --no-cache amazon-corretto-17=$version-r0 && \
  rm -rf /usr/lib/jvm/java-17-amazon-corretto/lib/src.zip

ENV LANG C.UTF-8

ENV JAVA_HOME=/usr/lib/jvm/default-jvm
ENV PATH=$PATH:/usr/lib/jvm/default-jvm/bin

ENV dl_src="https://archive.apache.org/dist/kafka/${kafka_version}/kafka_${scala_version}-${kafka_version}.tgz"

RUN set -ex; \
  wget "$dl_src" -O /tmp/kafka.tgz; \
  cd /tmp && tar -xf kafka.tgz; \
  rm -f /tmp/kafka.tgz; \
  mv /tmp/kafka_* kafka

ENV KAFKA_HOME="/opt/kafka"
ENV KAFKA_BIN="$KAFKA_HOME/bin"
ENV KAFKA_CONF="$KAFKA_HOME/config"
ENV KAFKA_DATA="$KAFKA_HOME/data"

RUN mv /tmp/kafka $KAFKA_HOME
RUN mkdir -p $KAFKA_DATA
RUN chown -R mich43l:mich43l $KAFKA_HOME

ADD units /
RUN chmod +x /etc/service/*/*

WORKDIR $KAFKA_HOME