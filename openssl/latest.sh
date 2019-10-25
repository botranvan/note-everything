#/bin/bash
set -o xtrace
password='tranbo9x'
path=/root/ca
read -p "Input Common Name for certs: " commonname
mkdir $path
cd $path
mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
wget -O openssl.cnf https://jamielinux.com/docs/openssl-certificate-authority/_downloads/root-config.txt
echo "Create the root key"
cd $path
openssl genrsa -passout pass:$password -aes256 -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem

openssl req -config openssl.cnf -key private/ca.key.pem -new -x509 -days 7300 -sha256 -extensions v3_ca -out certs/ca.cert.pem
chmod 444 certs/ca.cert.pem

echo "Verify the root certificate"
openssl x509 -noout -text -in certs/ca.cert.pem

echo "Create the intermediate pair"
mkdir $path/intermediate
cd $path/intermediate
mkdir certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > $path/intermediate/crlnumber
wget -O openssl.cnf https://jamielinux.com/docs/openssl-certificate-authority/_downloads/intermediate-config.txt
cd $path
openssl genrsa -passout pass:$password -aes256 -passout pass:$password -out $path/intermediate/private/intermediate.key.pem 4096
chmod 400 intermediate/private/intermediate.key.pem

echo "Create the intermediate certificate"
cd $path
openssl req -config intermediate/openssl.cnf -new -sha256 -key intermediate/private/intermediate.key.pem -out intermediate/csr/intermediate.csr.pem

cd $path
openssl ca -config openssl.cnf -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in intermediate/csr/intermediate.csr.pem -out intermediate/certs/intermediate.cert.pem
chmod 444 intermediate/certs/intermediate.cert.pem

echo "Verify the intermediate certificate"
openssl x509 -noout -text -in intermediate/certs/intermediate.cert.pem

echo "Create the certificate chain file"
cat intermediate/certs/intermediate.cert.pem certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem
chmod 444 intermediate/certs/ca-chain.cert.pem

echo "Sign server and client certificates"
cd $path
openssl genrsa -passout pass:$password -aes256 -passout pass:$password -out intermediate/private/$commonname.key.pem 2048
chmod 400 intermediate/private/$commonname.key.pem

echo "Create a certificate"
cd $path
openssl req -config intermediate/openssl.cnf  -key intermediate/private/$commonname.key.pem -new -sha256 -out intermediate/csr/$commonname.csr.pem

cd $path
openssl ca -config intermediate/openssl.cnf -extensions server_cert -days 375 -notext -md sha256 -in intermediate/csr/$commonname.csr.pem -out intermediate/certs/$commonname.cert.pem
chmod 444 intermediate/certs/$commonname.cert.pem

echo "Verify the certificate"
openssl x509 -noout -text -in intermediate/certs/$commonname.cert.pem

set +o xtrace
