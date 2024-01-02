SR_CA=/etc/schema-registry/kafka.client.truststore.pkcs12
export SCHEMA_REGISTRY_KAFKASTORE_SSL_TRUSTSTORE_LOCATION=$SR_CA
export SCHEMA_REGISTRY_KAFKASTORE_SSL_TRUSTSTORE_PASSWORD=$P12_PASS
export SCHEMA_REGISTRY_KAFKASTORE_SASL_JAAS_CONFIG="org.apache.kafka.common.security.plain.PlainLoginModule required \ username=\"client\" \ password=\"${USER_CLIENT}\";"

export PASSWORD_FILE=/etc/schema-registry/passwd
export JAAS_CONFIG=/etc/schema-registry/schema-registry.jaas

echo "client: $SR_PASSWORD,developer" > $PASSWORD_FILE
echo "
SchemaRegistry-Props {
  org.eclipse.jetty.jaas.spi.PropertyFileLoginModule required
  file=\"$PASSWORD_FILE\"
  debug=\"false\";
};
" > $JAAS_CONFIG


# set auth config env vars
export SCHEMA_REGISTRY_AUTHENTICATION_METHOD=BASIC
export SCHEMA_REGISTRY_AUTHENTICATION_ROLES=admin,developer
export AUTHENTICATION_REALM=SchemaRegistry-Props
export SCHEMA_REGISTRY_OPTS=-Djava.security.auth.login.config=$JAAS_CONFIG

keytool -keystore $SR_CA \
-alias CARoot \
-import \
-file /etc/ca/ca.crt \
-storepass $P12_PASS  \
-noprompt \
-storetype PKCS12

/etc/confluent/docker/run
