#!/bin/sh

PORT=6379

if [[ -r /opt/redis/ssl/server.crt && -r /opt/redis/ssl/server.key && \
      -r /opt/redis/ssl/ca.crt && -r /opt/redis/ssl/dh_params.dh ]]; then
    /opt/redis/src/redis-server --loglevel debug  --enable-ssl yes \
    --certificate-file /opt/redis/ssl/server.crt \
    --private-key-file /opt/redis/ssl/server.key \
    --root-ca-certs-path /opt/redis/ssl/ca.crt \
    --dh-params-file /opt/redis/ssl/dh_params.dh \
    --protected-mode no \
    --port ${PORT}
else
    echo "Required certificate-files: server.crt, server.key, ca.crt and dh_params.dh in /opt/redis/ssl"
fi
