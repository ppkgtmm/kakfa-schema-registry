# export JAAS config env var
JAAS_CNF="org.apache.kafka.common.security.plain.PlainLoginModule required \ username=\"$USERNAME\" \ password=\"$PASSWORD\" \ user_admin=\"$USER_ADMIN\" \ user_client=\"$USER_CLIENT\";"
export KAFKA_LISTENER_NAME_INTERNAL_PLAIN_SASL_JAAS_CONFIG=$JAAS_CNF
export KAFKA_LISTENER_NAME_EXTERNAL_PLAIN_SASL_JAAS_CONFIG=$JAAS_CNF

# create broker key store and import cert
keytool -importkeystore \
-deststorepass $P12_PASS \
-destkeystore /etc/kafka/secrets/kafka.$BROKER.keystore.pkcs12 \
-srckeystore /etc/kafka/secrets/$BROKER.p12 \
-deststoretype PKCS12  \
-srcstoretype PKCS12 \
-noprompt \
-srcstorepass $P12_PASS

echo $P12_PASS > /etc/kafka/secrets/${BROKER}_sslkey_creds 
# sudo tee /etc/${BROKER}_sslkey_creds << EOF >/dev/null
# $P12_PASS
# EOF
echo $P12_PASS > /etc/kafka/secrets/${BROKER}_keystore_creds
# sudo tee /etc/${BROKER}_keystore_creds << EOF >/dev/null
# $P12_PASS
# EOF

/etc/confluent/docker/run
