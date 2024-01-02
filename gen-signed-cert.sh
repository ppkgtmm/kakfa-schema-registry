# get env vars from .env file
source .env

# create ca folder if not exists
mkdir -p $SC_DIR/ca

# gen certification authority key and certificate
openssl req -new -nodes -x509 -days 365 -newkey rsa:2048 \
-keyout $CA_KEY \
-out $CA_CERT \
-config $CA_CNF

# concat ca cert and key into .pem file
cat $CA_CERT $CA_KEY > $CA_PEM

# for each broker
for BROKER in $BROKER1 $BROKER2 $BROKER3 $SR_HOST
do
# create broker folder if not exists
mkdir -p $SC_DIR/$BROKER/

# gen config file from template
echo "[req]
prompt = no
distinguished_name = dn
default_md = sha256
default_bits = 4096
req_extensions = v3_req

[ dn ]
countryName = US
organizationName = CONFLUENT
localityName = MountainView
commonName=$BROKER

[ v3_ca ]
subjectKeyIdentifier=hash
basicConstraints = critical,CA:true
authorityKeyIdentifier=keyid:always,issuer:always
keyUsage = critical,keyCertSign,cRLSign

[ v3_req ]
subjectKeyIdentifier = hash
basicConstraints = CA:FALSE
nsComment = 'OpenSSL Generated Certificate'
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names

[ alt_names ]
DNS.1=$BROKER
DNS.2=$BROKER-external
DNS.3=localhost" > $CNF_DIR/$BROKER.cnf

# gen broker key and cert
openssl req -new -newkey rsa:2048 -nodes \
-keyout $SC_DIR/$BROKER/$BROKER.key \
-out $SC_DIR/$BROKER/$BROKER.csr \
-config $CNF_DIR/$BROKER.cnf

# sign broker cert from ca
openssl x509 -req -days 3650 \
-in $SC_DIR/$BROKER/$BROKER.csr \
-CA $CA_CERT \
-CAkey $CA_KEY \
-CAcreateserial \
-out $SC_DIR/$BROKER/$BROKER.crt \
-extfile $CNF_DIR/$BROKER.cnf \
-extensions v3_req

# convert broker cert to pkcs12 (language neutral) format
openssl pkcs12 -export \
-in $SC_DIR/$BROKER/$BROKER.crt \
-inkey $SC_DIR/$BROKER/$BROKER.key \
-chain \
-CAfile $CA_PEM \
-name $BROKER \
-out $SC_DIR/$BROKER/$BROKER.p12 \
-password pass:$P12_PASS
done

# create trust store and import ca cert for broker cert verification
keytool -delete -noprompt -alias $ALIAS -keystore $TRUST_STORE -storepass $P12_PASS
keytool -keystore $TRUST_STORE \
-alias $ALIAS \
-import \
-file $CA_CERT \
-storepass $P12_PASS  \
-noprompt \
-storetype PKCS12
