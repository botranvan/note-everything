# Create directories
CERT_DIR=/etc/octavia/certs
OPEN_SSL_CONF=/opt/stack/octavia/etc/certificates/openssl.cnf
VALIDITY_DAYS=${3:-18250} # defaults to 50 years

echo $CERT_DIR


# mkdir -p $CERT_DIR
cd $CERT_DIR
mkdir newcerts private
chmod 700 private

# prepare files
touch index.txt
echo 01 > serial


echo "Create the CA's private and public keypair (2k long)"
openssl genrsa -passout pass:Welcome123 -des3 -out private/cakey.pem 2048

echo "You will be asked to enter some information about the certificate."

openssl req -x509 -passin pass:Welcome123 -new -nodes -key private/cakey.pem \
        -config $OPEN_SSL_CONF \
        -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" \
        -days $VALIDITY_DAYS \
        -out ca_01.pem


echo "Here is the certificate"
openssl x509 -in ca_01.pem -text -noout


## Create Server/Client CSR
echo "Generate a server key and a CSR"
openssl req \
       -newkey rsa:2048 -nodes -keyout client.key \
       -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" \
       -out client.csr

echo "Sign request"
openssl ca -passin pass:Welcome123 -config $OPEN_SSL_CONF -in client.csr \
           -days $VALIDITY_DAYS -out client-.pem -batch

echo "Generate single pem client.pem"
cat client-.pem client.key > client.pem

octavia_conf="/etc/octavia/octavia.conf"
crudini --set $octavia_conf controller_worker client_ca /etc/octavia/certs/ca_01.pem

crudini --set $octavia_conf certificates ca_certificate /etc/octavia/certs/ca_01.pem
crudini --set $octavia_conf certificates ca_private_key /etc/octavia/certs/private/cakey.pem
crudini --set $octavia_conf certificates ca_private_key_passphrase Welcome123

crudini --set $octavia_conf haproxy_amphora client_cert /etc/octavia/certs/client.pem
crudini --set $octavia_conf haproxy_amphora server_ca /etc/octavia/certs/ca_01.pem
crudini --set $octavia_conf certificates cert_generator local_cert_generator
