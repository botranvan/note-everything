#!/bin/sh
apk update
apk add perl git curl make gcc gcc-objc tcl-tls tcl linux-headers
git clone https://github.com/madolson/redis
cd redis/deps
sed -i '1s/bash/sh/g' download-ssl-deps.sh
./download-ssl-deps.sh
cd openssl
./config --prefix=/usr/local --openssldir=/usr/local/openssl
make
make install
cp -R /usr/local/include/openssl /usr/include/
cd /building/redis
BUILD_SSL=yes make


rm -rf /building/redis/ssl && mkdir -p /building/redis/ssl
cat > /building/redis/ssl/ca_config.conf << _EOF_
[ req ]
default_bits       = 4096
default_md         = sha512
default_keyfile    = domain.com.key
prompt             = no
encrypt_key        = no
distinguished_name = req_distinguished_name
# distinguished_name
[ req_distinguished_name ]
countryName            = "XX"                     # C=
localityName           = "XXXXX"                 # L=
organizationName       = "My Company"             # O=
organizationalUnitName = "Department"            # OU=
commonName             = "*"           # CN=
emailAddress           = "me@domain.com"          # email
_EOF_

# Create CA Bundle
openssl genrsa -out /building/redis/ssl/ca.key 2048
openssl req -x509 -new -nodes -key /building/redis/ssl/ca.key -sha256 -days 1024 -out /building/redis/ssl/ca.crt -config /building/redis/ssl/ca_config.conf

# Create Server Certificates
openssl genrsa -out /building/redis/ssl/server.key 2048
openssl req -new -key /building/redis/ssl/server.key -out /building/redis/ssl/server.csr -config /building/redis/ssl/ca_config.conf
openssl x509 -req -days 360 -in /building/redis/ssl/server.csr -CA /building/redis/ssl/ca.crt -CAkey /building/redis/ssl/ca.key -CAcreateserial -out /building/redis/ssl/server.crt

# Generate DH params file
openssl dhparam -out /building/redis/ssl/dh_params.dh 2048
