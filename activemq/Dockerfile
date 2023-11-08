FROM openjdk:bullseye

ARG VERSION

ENV ACTIVEMQ_VERSION $VERSION
ENV ACTIVEMQ apache-activemq-$ACTIVEMQ_VERSION
ENV ACTIVEMQ_HOME /opt/activemq

RUN apt update && apt install net-tools -yqq && rm -rf /var/lib/apt/lists/*

RUN wget -O $ACTIVEMQ-bin.tar.gz https://dlcdn.apache.org//activemq/$ACTIVEMQ_VERSION/apache-activemq-$ACTIVEMQ_VERSION-bin.tar.gz && \
    tar -xvzf $ACTIVEMQ-bin.tar.gz && \
    rm -f $ACTIVEMQ-bin.tar.gz && \
    mv $ACTIVEMQ $ACTIVEMQ_HOME && \
    useradd -r -M -d $ACTIVEMQ_HOME activemq && \
    chown -R activemq:activemq $ACTIVEMQ_HOME && \
    chown -h activemq:activemq $ACTIVEMQ_HOME 

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

USER activemq

WORKDIR $ACTIVEMQ_HOME
ENTRYPOINT ["/docker-entrypoint.sh"]