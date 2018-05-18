Kafka in Docker
===

Status: **ALPHA**

Revamped version of: https://github.com/spotify/docker-kafka

Mostly working, but still in development.

In this version of the image, you can bring up multiple brokers within the same container, also exposing the JMX port.

The `kafkaproxy` is left untouched.

Why?
---
The main hurdle of running Kafka in Docker is that it depends on Zookeeper.
Compared to other Kafka docker images, this one runs both Zookeeper and Kafka
in the same container. This means:

* No dependency on an external Zookeeper host, or linking to another container
* Zookeeper and Kafka are configured to work together out of the box

Run
---

```bash
docker run -p 2181:2181 -p 9092:9092 -p 19092:19092 -p 9093:9093 -p 19093:19093 -e BROKER_COUNT=2 nicovillanueva/kafka
```

This configures and brings up two brokers: Each exposed in 9092 and 9093 respectively; and 19092 & 19093 for each broker's JMX port.
If you add to the BROKER_COUNT, you should also expose the corresponding port.


Build from Source
---

    docker build -t nicovillanueva/kafka kafka/
