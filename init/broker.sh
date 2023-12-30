# define vars for reuse
JAAS_CNF="org.apache.kafka.common.security.plain.PlainLoginModule required \ username=\"$USERNAME\" \ password=\"$PASSWORD\" \ user_admin=\"$USER_ADMIN\" \ user_client=\"$USER_CLIENT\";"
SSL_STORE_TYPE=PKCS12

# set JAAS config env vars
export KAFKA_LISTENER_NAME_INTERNAL_PLAIN_SASL_JAAS_CONFIG=$JAAS_CNF
export KAFKA_LISTENER_NAME_EXTERNAL_PLAIN_SASL_JAAS_CONFIG=$JAAS_CNF

# set SASL mechanism
export KAFKA_SASL_ENABLED_MECHANISMS=PLAIN
export KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL=PLAIN

# set ssl related env vars
export KAFKA_SSL_KEYSTORE_LOCATION=/etc/kafka/secrets/kafka.$BROKER.keystore.pkcs12
export KAFKA_SSL_KEYSTORE_PASSWORD=$P12_PASS
export KAFKA_SSL_KEY_PASSWORD=$P12_PASS
export KAFKA_SSL_TRUSTSTORE_LOCATION=/etc/kafka/secrets/kafka.$BROKER.truststore.pkcs12
export KAFKA_SSL_TRUSTSTORE_PASSWORD=$P12_PASS
export KAFKA_SSL_TRUSTSTORE_TYPE=$SSL_STORE_TYPE
# export KAFKA_SSL_ENDPOINT_IDENTIFICATION_ALGORITHM=HTTPS

# create broker key store and import cert
keytool -delete -noprompt -keystore $KAFKA_SSL_KEYSTORE_LOCATION -storepass $P12_PASS
keytool -importkeystore \
-deststorepass $P12_PASS \
-destkeystore $KAFKA_SSL_KEYSTORE_LOCATION \
-srckeystore /etc/kafka/secrets/$BROKER.p12 \
-deststoretype $SSL_STORE_TYPE  \
-srcstoretype $SSL_STORE_TYPE \
-noprompt \
-srcstorepass $P12_PASS


# create broker trust store and import ca cert
keytool -delete -noprompt -alias CARoot -keystore $KAFKA_SSL_TRUSTSTORE_LOCATION -storepass $P12_PASS
keytool -keystore $KAFKA_SSL_TRUSTSTORE_LOCATION \
-alias CARoot \
-import \
-file /etc/ca/ca.crt \
-storepass $P12_PASS  \
-noprompt \
-storetype $SSL_STORE_TYPE

/etc/confluent/docker/run
