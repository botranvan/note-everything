# Cách build images

- Change directory path:

        cd note-everything/redis-ssl
        
- Build image docker:

        docker build -t redis-ssl .
        

- Để overwirte certificate-file, ta cần thực hiện mount một volume bao gồm các file sau: 

        --certificate-file /opt/redis/ssl/server.crt
        --private-key-file /opt/redis/ssl/server.key
        --root-ca-certs-path /opt/redis/ssl/ca.crt
        --dh-params-file /opt/redis/ssl/dh_params.dh

tới thư mục `/opt/redis/ssl` . Ví dụ:

        docker run -it --rm -v new_certs_path:/opt/redis/ssl image_name.
        
