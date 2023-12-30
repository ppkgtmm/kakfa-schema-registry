SR_CA=/etc/schema-registry/kafka.client.truststore.pkcs12
export SCHEMA_REGISTRY_KAFKASTORE_SSL_TRUSTSTORE_LOCATION=$SR_CA
export SCHEMA_REGISTRY_KAFKASTORE_SSL_TRUSTSTORE_PASSWORD=$P12_PASS
export SCHEMA_REGISTRY_KAFKASTORE_SASL_JAAS_CONFIG="org.apache.kafka.common.security.plain.PlainLoginModule required \ username=\"client\" \ password=\"${USER_CLIENT}\";"

keytool -keystore $SR_CA \
-alias CARoot \
-import \
-file /etc/ca/ca.crt \
-storepass $P12_PASS  \
-noprompt \
-storetype PKCS12

/etc/confluent/docker/run
