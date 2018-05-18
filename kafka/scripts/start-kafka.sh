#!/bin/sh

# Optional ENV variables:
# * LOG_RETENTION_HOURS: the minimum age of a log file in hours to be eligible for deletion (default is 168, for 1 week)
# * LOG_RETENTION_BYTES: configure the size at which segments are pruned from the log, (default is 1073741824, for 1GB)
# * NUM_PARTITIONS: configure the default number of log partitions per topic
# * AUTO_CREATE_TOPICS
# * BROKER_COUNT

# General configurations

# Allow specification of log retention policies
if [ ! -z "$LOG_RETENTION_HOURS" ]; then
    echo "log retention hours: $LOG_RETENTION_HOURS"
    sed -r -i "s/(log.retention.hours)=(.*)/\1=$LOG_RETENTION_HOURS/g" $KAFKA_HOME/config/server.properties
fi
if [ ! -z "$LOG_RETENTION_BYTES" ]; then
    echo "log retention bytes: $LOG_RETENTION_BYTES"
    sed -r -i "s/#(log.retention.bytes)=(.*)/\1=$LOG_RETENTION_BYTES/g" $KAFKA_HOME/config/server.properties
fi

# Configure the default number of log partitions per topic
if [ ! -z "$NUM_PARTITIONS" ]; then
    echo "default number of partition: $NUM_PARTITIONS"
    sed -r -i "s/(num.partitions)=(.*)/\1=$NUM_PARTITIONS/g" $KAFKA_HOME/config/server.properties
fi

# Enable/disable auto creation of topics
if [ ! -z "$AUTO_CREATE_TOPICS" ]; then
    echo "auto.create.topics.enable: $AUTO_CREATE_TOPICS"
    echo "auto.create.topics.enable=$AUTO_CREATE_TOPICS" >> $KAFKA_HOME/config/server.properties
fi

ADVERTISED_HOST=${ADVERTISED_HOST:-"localhost"}  # En Marathon, ADVERTISED_HOST debería ser el propio FQDN (y correr en modo Host)
sed -r -i "s/#(advertised.host.name)=(.*)/\1=$ADVERTISED_HOST/g" $KAFKA_HOME/config/server.properties

# ------

mkdir -p "/var/log/kafka/"
for BRKID in $(seq 0 $((${BROKER_COUNT:-1}-1))); do
    echo "Configuring broker $BRKID"
    cp $KAFKA_HOME/config/server.properties $KAFKA_HOME/config/server.properties-$BRKID
    BRKPORT=$((9092+$BRKID))
    sed -r -i "s/#BROKERID#/$BRKID/g" $KAFKA_HOME/config/server.properties-$BRKID
    sed -r -i "s/#BROKERPORT#/$BRKPORT/g" $KAFKA_HOME/config/server.properties-$BRKID
    JMX_PORT="1$BRKPORT" $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties-$BRKID &> /var/log/kafka/broker-$BRKID.log &
done
wait
