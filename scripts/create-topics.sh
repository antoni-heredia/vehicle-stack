#!/bin/bash
set -e
topics=("vehicle-data")

for t in "${topics[@]}"; do
  echo "Creando topic $t ..."
  /opt/kafka/bin//kafka-topics.sh \
    --bootstrap-server kafka:9092 \
    --create --topic "$t" \
    --partitions 3 --replication-factor 1 || true
done

/opt/kafka/bin//kafka-topics.sh --list --bootstrap-server kafka:9092