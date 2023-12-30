import argparse
import pandas as pd

from confluent_kafka import Producer
from confluent_kafka.serialization import (
    StringSerializer,
    SerializationContext,
    MessageField,
)
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.avro import AvroSerializer, AvroDeserializer
from common import *


def delivery_report(err, msg):
    value = avro_deserializer(
        msg.value(), SerializationContext(topic, MessageField.VALUE)
    )
    if err is not None:
        print("Delivery failed for User record {}: {}".format(value, err))


def main(data_path: str):
    data = pd.read_csv(data_path)
    producer = Producer(kafka_server_conf)

    print("Producing user records to topic {}".format(topic))
    for user in data.to_dict(orient="records"):
        # Serve on_delivery callbacks from previous calls to produce()
        producer.poll(0.0)
        try:
            producer.produce(
                topic=topic,
                key=string_serializer(user.get("gender", "")),
                value=avro_serializer(
                    user, SerializationContext(topic, MessageField.VALUE)
                ),
                on_delivery=delivery_report,
            )
        except ValueError:
            print("Invalid input {}, discarding record...".format(user))
    # Serve on_delivery callbacks for pending records
    print("Flushing records...")
    producer.flush()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Kafka producer")
    parser.add_argument("--data", required=True, help="Path to data file")
    parser.add_argument("--version", required=True, help="schema version e.g. v1")
    arguments = parser.parse_args()

    create_topic(topic)

    schema = get_current_schema(arguments.version)

    schema_registry_client = SchemaRegistryClient(schema_registry_conf)
    avro_serializer = AvroSerializer(schema_registry_client, schema)
    avro_deserializer = AvroDeserializer(schema_registry_client, schema)
    string_serializer = StringSerializer()

    main(arguments.data)
