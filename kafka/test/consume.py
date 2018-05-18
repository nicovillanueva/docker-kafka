from kafka import KafkaConsumer

consumer = KafkaConsumer('test-topic', bootstrap_servers='localhost:9092')
print("listening")
for msg in consumer:
    print(msg)
