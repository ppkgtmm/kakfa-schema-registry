import dataclasses
from dataclasses_avroschema import AvroModel
from dotenv import load_dotenv
import os
from confluent_kafka.admin import AdminClient, NewTopic

load_dotenv()

schema_registry_conf = {"url": "http://localhost:8081"}
kafka_server_conf = {
    "bootstrap.servers": "localhost:9092,localhost:9093,localhost:9094",
    "security.protocol": "SASL_SSL",
    "sasl.mechanism": "PLAIN",
    "sasl.username": "client",
    "sasl.password": os.environ.get("USER_CLIENT"),
}
producer_conf = {
    **kafka_server_conf,
    "ssl.truststore.location": os.environ.get("TRUST_STORE"),
    "ssl.truststore.password": os.environ.get("P12_PASS"),
}
admin_conf = {
    **kafka_server_conf,
    "ssl.ca.location": os.environ.get("CA_CERT"),
}
topic = "users"


@dataclasses.dataclass
class UserV1(AvroModel):
    first_name: str
    last_name: str
    email: str
    gender: str


@dataclasses.dataclass
class UserV2(AvroModel):
    first_name: str
    last_name: str
    email: str
    gender: str
    country: str


@dataclasses.dataclass
class UserV3(AvroModel):
    first_name: str
    last_name: str
    email: str
    gender: str
    country: str = None


data_class = {"v1": UserV1, "v2": UserV2, "v3": UserV3}


def create_topic(topic: str):
    admin = AdminClient(admin_conf)
    topics = admin.list_topics().topics
    if topic in topics:
        return
    admin.create_topics(
        new_topics=[NewTopic(topic, num_partitions=3, replication_factor=3)]
    )
