#!/bin/bash
set -e
cd $ACTIVEMQ_HOME
sed -i "s/user: user, user//g" conf/jetty-realm.properties
sed -i "s/guest.*//g" conf/credentials.properties
sed -i "s/127.0.0.1/0.0.0.0/g" conf/jetty.xml

if [ -n "$ACTIVEMQ_USERNAME" ]; then
  echo "Setting activemq username to $ACTIVEMQ_USERNAME"
  sed -i "s#activemq.username=system#activemq.username=$ACTIVEMQ_USERNAME#" conf/credentials.properties
fi

if [ -n "$ACTIVEMQ_PASSWORD" ]; then
  echo "Setting activemq password"
  sed -i "s#activemq.password=manager#activemq.password=$ACTIVEMQ_PASSWORD#" conf/credentials.properties
fi

if [ ! -z "${ACTIVEMQ_WEBADMIN_USERNAME}" ] && [ ! -z "${ACTIVEMQ_WEBADMIN_PASSWORD}" ]; then
  sed -i "s/admin.*/"${ACTIVEMQ_WEBADMIN_USERNAME}": "${ACTIVEMQ_WEBADMIN_PASSWORD}", admin/g" conf/jetty-realm.properties
elif [ ! -z "${ACTIVEMQ_WEBADMIN_PASSWORD}" ]; then
  sed -i "s/admin.*/admin: "${ACTIVEMQ_WEBADMIN_PASSWORD}", admin/g" conf/jetty-realm.properties
fi

bin/activemq console