# Cách cài đặt Trove trong Openstack

____

# Mục lục


- [1. Cài đặt](#install)
- [Các nội dung khác](#content-others)

____

# <a name="content">Nội dung</a>
- ### <a name="install">1. Cài đặt</a>
    - Yêu cầu:
        + Openstack đã được cài đặt bản rockey với đầy đủ các thành phần chính
        + Hệ điều hành sử dụng: Ubuntu
    - Tiến hành cài đặt:
        + Đầu tiên, ta cần tạo ra database để lưu các thông tin cho service như sau:

                mysql -e \
                "CREATE DATABASE trove;
                GRANT ALL PRIVILEGES ON trove.* TO 'trove'@'localhost'  IDENTIFIED BY 'Welcome123';
                GRANT ALL PRIVILEGES ON trove.* TO 'trove'@'%'  IDENTIFIED BY 'Welcome123';
                "
        trong đó: `Welcome123` là password để user trove truy cập tới database đã tạo.

        + Tiếp theo, ta cần thực hiện tạo ra thông tin đăng nhập service như sau:
            Lấy quyền admin user role:

                . admin-openrc

            Tạo ra người dùng trove:
                
                openstack user create --domain default trove --password Welcome123

            trong đó `Welcome123` là password được sử dụng cho user trove.

            Thêm role admin cho user trove:

                openstack role add --project service --user trove admin
            
            Tạo service entity:

                openstack service create --name trove --description "Database" database

            Tạo service API endpoint:

                openstack endpoint create --region RegionOne database admin http://{{ trove.admin_url }}/v1.0/%\(tenant_id\)s
                openstack endpoint create --region RegionOne database internal http://{{ trove.internal_url }}/v1.0/%\(tenant_id\)s
                openstack endpoint create --region RegionOne database public http://{{ trove.public_url }}/v1.0/%\(tenant_id\)s

            trong đó: `trove.admin_url`, `trove.internal_url` và `trove.public_url` lần lượt là các địa chỉ để truy cập đến các endpoint admin, internal và public.

            Tiếp theo, ta cần cài đặt các packages cần thiết để cài đặt trove service (ở đây, sẽ dụng apt để cài đặt):
                
                apt-get install -y python-trove python-troveclient python3-troveclient python-glanceclient trove-common trove-api trove-taskmanager trove-conductor python-trove-dashboard python3-trove-dashboard

            trong bước thực hiện này, ta hãy bỏ qua các phần cấu hình trước cho trove.

            Restart apache service để hiện thị dashboard cho trove:

                service apache2 restart

            Tiếp theo, ta sẽ thực hiện cấu hình cho trove-api (các file config nằm ở thư mục `/etc/trove`):

                # trove.conf
                [DEFAULT]
                log_dir = /var/log/trove
                trove_auth_url = http://{{ keystone.internal_url }}/identity
                nova_compute_url = http://{{ compute.internal_url }}/v2
                cinder_url = http://{{ cinder.internal_url }}/v3
                rpc_backend = rabbit
                transport_url = rabbit://{{ message_queue.username }}:{{ message_queue.password }}@{{ message_queue.listen_ip }}
                ...
                [database]
                connection = mysql+pymysql://trove:{{ database_trove_password }}@{{ mysql_database.listen_ip }}/trove
                ...
                [keystone_authtoken]
                auth_strategy = keystone
                add_addresses = True
                api_paste_config = /etc/trove/api-paste.ini
                www_authenticate_uri = http://{{ keystone.internal_url }}/identity
                auth_url = http://{{ keystone.internal_url }}/identity
                auth_type = password
                project_domain_name = default
                user_domain_name = default
                project_name = service
                username = trove
                password = {{ trove.password }}

            thay thế:
            - `keystone.internal_url`,`compute.internal_url` và `cinder.internal_url` lần lượt là địa chỉ truy cập tới public endpoint của keystone và nova, cinder.
            - `message_queue.username`, `message_queue.password` và `message_queue.listen_ip` lần lượt là username, password và và địa chỉ cung cấp rpc service.
            - `database_trove_password`, `mysql_database.listen` lần lượt là password của user trove, và địa chỉ IP để trove có thể sử dụng database.

            Tiếp theo, ta cấu hình cho trove-taskmanager như sau:

                # trove-taskmanager.conf
                [DEFAULT]
                log_dir =  /var/log/trove
                trove_auth_url =  http://{{ keystone.internal_url }}/identity
                nova_compute_url =  http://{{ compute.internal_url }}/v2
                cinder_url =  http://{{ cinder.internal_url }}/v3
                rpc_backend =  rabbit
                transport_url =  rabbit://{{ message_queue.username }}:{{ message_queue.password }}@{{ message_queue.listen_ip }}
                nova_proxy_admin_user =  {{ compute.proxy_admin_user }}
                nova_proxy_admin_pass =  {{ compute.proxy_admin_pass }}
                nova_proxy_admin_tenant_name =  service
                nova_proxy_admin_tenant_id =  {{ NOVA_PROXY_ADMIN_TENANT_ID }}
                taskmanager_manager trove.taskmanager.manager.Manager
                use_nova_server_config_drive True
                network_driver trove.network.neutron.NeutronDriver
                network_label_regex ".*"
                ...
                [database]
                connection = mysql+pymysql://trove:{{ database_trove_password }}@{{ mysql_database.listen }}/trove
            
            trong đó: `NOVA_PROXY_ADMIN_TENANT_ID` là id của service nova, `compute.proxy_admin_user` và `compute.proxy_admin_pass` lần lượt là username và password được cấp quyền admin truy cập service nova (thường là user nova).

            Cuối cùng, ta cấu hình cho trove-conductor:

                # trove-conductor.conf
                [DEFAULT]
                log_dir = /var/log/trove
                trove_auth_url = http://{{ keystone.internal_url }}/identity
                nova_compute_url = http://{{ compute.internal_url }}/v2
                cinder_url = http://{{ cinder.internal_url }}/v3
                rpc_backend = rabbit
                transport_url = rabbit://{{ message_queue.username }}:{{ message_queue.password }}@{{ message_queue.listen }}
                ...
                [database]
                connection = mysql+pymysql://trove:{{ database_trove_password }}@{{ mysql_database.listen }}/trove

            Ta cần thực hiện kiểm tra trong thư mục `/etc/trove` xem đã có file `api-paste.ini` hay chưa. Nếu chưa có thì ta thực hiện chạy câu lệnh dưới đây:

                cat << EOF > /etc/trove/api-paste.ini
                [composite:trove]
                use = call:trove.common.wsgi:versioned_urlmap
                /: versions
                /v1.0: troveapi

                [app:versions]
                paste.app_factory = trove.versions:app_factory

                [pipeline:troveapi]
                pipeline = cors http_proxy_to_wsgi faultwrapper osprofiler authtoken authorization contextwrapper ratelimit extensions troveapp
                #pipeline = debug extensions troveapp

                [filter:extensions]
                paste.filter_factory = trove.common.extensions:factory

                [filter:authtoken]
                paste.filter_factory = keystonemiddleware.auth_token:filter_factory

                [filter:authorization]
                paste.filter_factory = trove.common.auth:AuthorizationMiddleware.factory

                [filter:cors]
                paste.filter_factory = oslo_middleware.cors:filter_factory
                oslo_config_project = trove

                [filter:contextwrapper]
                paste.filter_factory = trove.common.wsgi:ContextMiddleware.factory

                [filter:faultwrapper]
                paste.filter_factory = trove.common.wsgi:FaultWrapper.factory

                [filter:ratelimit]
                paste.filter_factory = trove.common.limits:RateLimitingMiddleware.factory

                [filter:osprofiler]
                paste.filter_factory = osprofiler.web:WsgiMiddleware.factory

                [app:troveapp]
                paste.app_factory = trove.common.api:app_factory

                #Add this filter to log request and response for debugging
                [filter:debug]
                paste.filter_factory = trove.common.wsgi:Debug

                [filter:http_proxy_to_wsgi]
                use = egg:oslo.middleware#http_proxy_to_wsgi
                EOF

            Về cơ bản, thì ta đã thực hiện cấu hình cho trove service xong. Nhưng ta vẫn cần phải cấu hình cho guestagent (file cấu hình trove-guestagent.conf).

                # trove-guestagent.conf
                [DEFAULT]
                transport_url = rabbit://{{ message_queue.username }}:{{ message_queue.password }}@{{ message_queue.listen_ip }}
                ...
                [oslo_messaging_rabbit]
                rabbit_host {{ message_queue.listen_ip }}

        + Populate database trove với câu lệnh sau:

                su -s /bin/sh -c "trove-manage db_sync" trove

        + Restart lại services:

                service trove-api restart
                service trove-taskmanager restart
                service trove-conductor restart

____

# <a name="content-others">Các nội dung khác</a>
