from kafka import KafkaProducer
import time

producer = KafkaProducer(bootstrap_servers='localhost:9092')
i = 0
while True:
    m = "test message {}".format(i)
    producer.send("test-topic", bytes(m.encode()))
    print("sent {}".format(m))
    time.sleep(0.1)
    i += 1
