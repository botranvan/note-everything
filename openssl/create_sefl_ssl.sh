#/bin/bash
set -o xtrace
cd /etc/octavia
mkdir certs
chmod 700 certs
cd certs

wget https://raw.githubusercontent.com/BoTranVan/note-everything/master/openssl/openssl.cnf

mkdir client_ca
mkdir server_ca

cd server_ca
mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > index.txt
openssl genrsa -aes256 -passout pass:Welcome123 -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem
openssl req -config ../openssl.cnf -passin pass:Welcome123 -key private/ca.key.pem -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" -new -x509 -days 7300 -sha256 -extensions v3_ca -out certs/ca.cert.pem


cd ../client_ca
mkdir certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
openssl genrsa -aes256 -passout pass:Welcome123 -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem
openssl req -config ../openssl.cnf -passin pass:Welcome123 -key private/ca.key.pem -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" -new -x509 -days 7300 -sha256 -extensions v3_ca -out certs/ca.cert.pem
openssl genrsa -aes256 -passout pass:Welcome123 -out private/client.key.pem 2048
openssl req -config ../openssl.cnf -passin pass:Welcome123 -new -sha256 -key private/client.key.pem -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" -out csr/client.csr.pem

openssl ca -config ../openssl.cnf -passin pass:Welcome123 -extensions usr_cert -days 7300 -notext -md sha256 -in csr/client.csr.pem -out certs/client.cert.pem << _EOF_
y
y
_EOF_


openssl rsa -passin pass:Welcome123 -in private/client.key.pem -out private/client.cert-and-key.pem
cat certs/client.cert.pem >> private/client.cert-and-key.pem


chmod 700 /etc/octavia/certs
cp /etc/octavia/certs/server_ca/private/ca.key.pem /etc/octavia/certs/server_ca.key.pem
chmod 700 /etc/octavia/certs/server_ca.key.pem
cp /etc/octavia/certs/server_ca/certs/ca.cert.pem /etc/octavia/certs/server_ca.cert.pem
cp /etc/octavia/certs/client_ca/certs/ca.cert.pem /etc/octavia/certs/client_ca.cert.pem
cp /etc/octavia/certs/client_ca/private/client.cert-and-key.pem /etc/octavia/certs/client.cert-and-key.pem
chmod 700 /etc/octavia/certs/client.cert-and-key.pem
chown -R octavia.octavia /etc/octavia/certs


crudini --set /etc/octavia/octavia.conf certificates cert_generator local_cert_generator
crudini --set /etc/octavia/octavia.conf certificates ca_certificate /etc/octavia/certs/server_ca.cert.pem
crudini --set /etc/octavia/octavia.conf certificates ca_private_key /etc/octavia/certs/server_ca.key.pem
crudini --set /etc/octavia/octavia.conf certificates ca_private_key_passphrase Welcome123
crudini --set /etc/octavia/octavia.conf controller_worker client_ca /etc/octavia/certs/client_ca.cert.pem
crudini --set /etc/octavia/octavia.conf haproxy_amphora client_cert /etc/octavia/certs/client.cert-and-key.pem
crudini --set /etc/octavia/octavia.conf haproxy_amphora server_ca /etc/octavia/certs/server_ca.cert.pem
set +o xtrace
