# define var of reuse
SR_CA=/etc/schema-registry/$SR_HOST.truststore.pkcs12
SSL_STORE_TYPE=PKCS12
export SCHEMA_REGISTRY_KAFKASTORE_SSL_TRUSTSTORE_LOCATION=$SR_CA
export SCHEMA_REGISTRY_KAFKASTORE_SSL_TRUSTSTORE_PASSWORD=$P12_PASS
export SCHEMA_REGISTRY_KAFKASTORE_SASL_JAAS_CONFIG="org.apache.kafka.common.security.plain.PlainLoginModule required \ username=\"client\" \ password=\"${USER_CLIENT}\";"
export SCHEMA_REGISTRY_SSL_KEYSTORE_LOCATION=/etc/schema-registry/secrets/$SR_HOST.keystore.pkcs12
export SCHEMA_REGISTRY_SSL_KEYSTORE_PASSWORD=$P12_PASS
export SCHEMA_REGISTRY_SSL_KEY_PASSWORD=$P12_PASS
export SCHEMA_REGISTRY_SSL_TRUSTSTORE_TYPE=$SSL_STORE_TYPE
export PASSWORD_FILE=/etc/schema-registry/passwd
export JAAS_CONFIG=/etc/schema-registry/schema-registry.jaas

# save auth config to files
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
export SCHEMA_REGISTRY_AUTHENTICATION_REALM=SchemaRegistry-Props
export SCHEMA_REGISTRY_OPTS=-Djava.security.auth.login.config=$JAAS_CONFIG

# create sr key store and import cert
keytool -delete -noprompt -keystore $SCHEMA_REGISTRY_SSL_KEYSTORE_LOCATION -storepass $P12_PASS
keytool -importkeystore \
-deststorepass $P12_PASS \
-destkeystore $SCHEMA_REGISTRY_SSL_KEYSTORE_LOCATION \
-srckeystore /etc/schema-registry/secrets/$SR_HOST.p12 \
-deststoretype $SSL_STORE_TYPE  \
-srcstoretype $SSL_STORE_TYPE \
-noprompt \
-srcstorepass $P12_PASS

# create sr trust store and ca cert
keytool -keystore $SR_CA \
-alias CARoot \
-import \
-file /etc/ca/ca.crt \
-storepass $P12_PASS  \
-noprompt \
-storetype PKCS12

/etc/confluent/docker/run
