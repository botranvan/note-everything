# 2. Cài đặt Octavia

____

# Mục lục


- [2.1 Các yêu cầu](#requirements)
- [2.2 Mô hình cài đặt](#model)
- [2.3 Thực hiện cấu hình](#config)
- [2.4 Kiểm tra](#test)
- [Các nội dung khác](#content-others)

____

# <a name="content">Nội dung</a>

- ### <a name="requirements">2.1 Các yêu cầu</a>
    - Việc cài đặt và cấu hình được thực hiện trên:
        - Hệ điều hành sử dụng: Ubuntu 18.04
        - Phiên bản Openstack: rocky
        - Neutron networking (enable allowed_address_pairs) 
        - Openstack system có một đường mạng public (sử dụng đi ra internet, tạo vip)
        - Phải có amphora image và flavor tương ứng cùng các security group với các rule open port yêu cầu.


- ### <a name="model">2.2 Mô hình cài đặt</a>
    ![](../images/octavia-model-install.png)

    trong đó, đường mạng `lb-mgmt-net` có subnet là `192.168.89.0/24` được sử dụng để liên lạc với amphora.


- ### <a name="config">2.3 Thực hiện cấu hình</a>
    - Trên controller node, ta tiến hành tạo database lưu trữ các thông tin cho Octavia như sau:

            mysql
            CREATE DATABASE octavia;
            GRANT ALL PRIVILEGES ON octavia.* TO 'octavia'@'localhost' IDENTIFIED BY 'Welcome123';
            GRANT ALL PRIVILEGES ON octavia.* TO 'octavia'@'%' IDENTIFIED BY 'Welcome123';
    
        trong đó: `Welcome123` là password được sử dụng cho database octavia.
    - Tiếp theo, ta tiến hành cài đặt software packages:

            apt install -y python-octaviaclient python3-octaviaclient octavia-api \
            octavia-health-manager octavia-housekeeping \
            python3-octavia
        
    - Cài đặt `octavia dashboard`:

            pip install octavia-dashboard
            cp /usr/local/lib/python2.7/dist-packages/octavia_dashboard/enabled/_1482_project_load_balancer_panel.py /usr/share/openstack-dashboard/openstack_dashboard/enabled/
            ./usr/share/openstack-dashboard/manage.py collectstatic
            ./usr/share/openstack-dashboard/manage.py compress
            service apache2 restart

    - Tạo user octavia:

            openstack user create --password Welcome123 octavia

        trong đó: `Welcome123` là pasword của user octavia. 

    - Add role cho user octavia:

            openstack role add --user octavia --project service admin

    - Tạo endpoint để cung cấp API cho service octavia:

            openstack service create --name octavia load-balancer
            openstack endpoint create --region RegionOne load-balancer admin http://192.168.53.89:9876
            openstack endpoint create --region RegionOne load-balancer internal http://192.168.53.89:9876
            openstack endpoint create --region RegionOne load-balancer public http://192.168.53.89:9876
        
        trong đó:
        - `192.168.53.89` là địa chỉ IP của controller.
  
    - Chuyển sang user octavia để login vào project service, ta thực hiện tạo ra security group:

            openstack security group create lb-mgmt-sec-grp
            openstack security group rule create --protocol icmp lb-mgmt-sec-grp
            openstack security group rule create --protocol tcp --dst-port 22 lb-mgmt-sec-grp
            openstack security group rule create --protocol tcp --dst-port 9443 lb-mgmt-sec-grp
            openstack security group rule create --protocol icmpv6 --ethertype IPv6 --remote-ip ::/0 lb-mgmt-sec-grp
            openstack security group rule create --protocol tcp --dst-port 22 --ethertype IPv6 --remote-ip ::/0 lb-mgmt-sec-grp
            openstack security group rule create --protocol tcp --dst-port 9443 --ethertype IPv6 --remote-ip ::/0 lb-mgmt-sec-grp
            openstack security group create lb-health-mgr-sec-grp
            openstack security group rule create --protocol udp --dst-port 5555 lb-health-mgr-sec-grp
            openstack security group rule create --protocol udp --dst-port 5555 --ethertype IPv6 --remote-ip ::/0 lb-health-mgr-sec-grp
    
    - Tạo flavor cho amphora instance:

            openstack flavor create --ram 2048 --disk 5 --vcpus 4 amphora-2g-4c

    - Tạo network cho octavia thực hiện liên lạc với amphora:

            openstack network create lb-mgmt-private
            openstack subnet create --subnet-range 192.168.89.0/24 --gateway 192.168.89.1 \
            --network lb-mgmt-private --allocation-pool start=192.168.89.11,end=192.168.89.250 \
            --dns-nameserver 8.8.4.4 lb-mgmt-private
    
    - Tạo ra các port để bind vào các node cho việc liên lạc với amphora.

            # for controller.
            openstack port create --network lb-mgmt-private \
            --security-group lb-health-mgr-sec-grp \
            --device-owner Octavia:health-mgr \
            --host controller octavia-manage-controller-node

            # for compute1.
            openstack port create --network lb-mgmt-private \
            --security-group lb-health-mgr-sec-grp \
            --device-owner Octavia:health-mgr \
            --host compute1 octavia-manage-compute1-node

            # for compute2.
            openstack port create --network lb-mgmt-private \
            --security-group lb-health-mgr-sec-grp \
            --device-owner Octavia:health-mgr \
            --host compute2 octavia-manage-compute2-node

    - Add các port đã tạo vào openvswitch:

            ovs-vsctl --may-exist add-port br-int o-hm0 \
            -- set Interface o-hm0 type=internal \
            -- set Interface o-hm0 external-ids:iface-status=active \
            -- set Interface o-hm0 external-ids:attached-mac=fa:16:3e:ae:d4:4c  \
            -- set Interface o-hm0 external-ids:skip_cleanup=true \
            -- set Interface o-hm0 external-ids:iface-id=b64b0381-2b0f-4ec7-96dc-ce3cc617e1b8
        
        thay thế `fa:16:3e:ae:d4:4c` và `b64b0381-2b0f-4ec7-96dc-ce3cc617e1b8` tương ứng với địa chỉ MAC và ID của các port đã tạo ở trên, thay thế o-hm0 lần lượt với o-hm0, o-hm1, o-hm2. Đây sẽ là 3 port dùng để liên lạc với amphora.

    - UP port and request IP from DHCP Server:

            ip link set dev o-hm0 address fa:16:3e:ae:d4:4c
            dhclient -v o-hm0

        như vậy, controller node đã có thể liên lạc được với các amphora(nếu có).
        
    - Trên các node compute, tiến hành cài đặt octavia-worker như sau:

            apt install -y octavia-worker python3-octavia 

    - Tiếp theo, ta tiến hành build image amphora, để làm điều này, ta cần thực hiện clone source octavia:

            git clone https://github.com/openstack/octavia

        change dir:
            
            cd ~/octavia/diskimage-create
            pip install -r requirements.txt
            ./diskimage-create.sh -s 2 -o xenial-amphora.qcow2

        upload image tới glance:

            openstack image create --file /opt/stack/octavia/diskimage-create/xenial-amphora.qcow2 \
            --disk-format qcow2 --tag amphora xenial-amphora

        tại bước này, ta có thể sẽ cần lấy id của image vừa upload trên để cấu hình cho octavia.

    - Cho đến bước này, ta cần phải có certificates để cấu hình cho phép amphora liên lạc với octavia. Để tạo ra cert, ta sử dụng câu lệnh sau:

            cd /etc/octavia/certs && curl https://raw.githubusercontent.com/BoTranVan/note-everything/master/openssl/create_certificates.sh | sh
            chown -R octavia:octavia /etc/octavia/certs

    - Để tiện cho quá trình debug (nếu có), ta lên tạo ra một SSH key sử dụng cho octavia user, ví dụ:

            mkdir /etc/octavia/.ssh
            ssh-keygen << _EOF_
            /etc/octavia/.ssh/id_rsa


            _EOF_

            openstack keypair create --public-key /etc/octavia/.ssh/id_rsa.pub octavia-key

    - Các bước tiếp theo dưới đây sẽ thực hiện cấu hình cho Octavia, việc cấu hình được thực hiện bằng việc chỉnh sửa file `/etc/octavia/octavia.conf`:

            [DEFAULT]
            debug = True
            log_dir = /var/log/octavia
            transport_url = rabbit://openstack:Welcome123@192.168.53.89:5672

        trong đó: 
        - openstack và Welcome123 lần lượt là username và password có thể truy cập rabbitmq server
        - 192.168.53.89:5672: địa chỉ của rabbitmq server.

                [api_settings]
                bind_host = 0.0.0.0
                api_v1_enabled = False
                ...
                [database]
                connection = mysql+pymysql://octavia:Welcome123@192.168.53.89/octavia

        trong đó:
        - octavia và Welcome123 lần lượt là username và password có thể truy cập mysql server
        - 192.168.53.89/octavia là địa chỉ của mysql server và database truy cập.

                [health_manager]
                bind_ip = 0.0.0.0
                bind_port = 5555
                heartbeat_key = Welcome123
                controller_ip_port_list = 192.168.53.89:5555, [ip]:[port], ...

        thực hiện cấu hình health-manager, trong đó:
        - controller_ip_port_list: là danh sách địa chỉ(kèm port) để amphora có thể gửi heartbeat tới trong quá trình monitor.

                [keystone_authtoken]
                www_authenticate_uri = http://192.168.53.89:5000
                auth_url = http://192.168.53.89:5000
                memcached_servers = 192.168.53.89:11211
                auth_type = password
                project_domain_name = default
                user_domain_name = default
                project_name = service
                username = octavia
                password = Welcome123
                service_token_roles_required = True
        
        để cấu hình keytone authentication.

            [certificates]
            ca_certificate = /etc/octavia/certs/ca_01.pem
            ca_private_key = /etc/octavia/certs/private/cakey.pem
            ca_private_key_passphrase = foobar

            [haproxy_amphora]
            client_cert = /etc/octavia/certs/client.pem
            server_ca = /etc/octavia/certs/ca_01.pem

        để thực hiện cấu hình certificates và amphora.

            [controller_worker]
            client_ca = /etc/octavia/certs/ca_01.pem
            amp_active_retries = 10
            amp_active_wait_sec = 10
            amp_image_id = $AMP_IMAGE_ID
            amp_image_tag = amphora
            amp_image_owner_id = $AMP_IMAGE_OWNER_ID
            amp_flavor_id = $AMP_FLAVOR_ID
            amp_ssh_key_name = octavia-key
            amp_boot_network_list = $AMP_BOOT_NETWORK_LIST
            amp_secgroup_list = $AMP_SECGROUP_LIST
            amphora_driver = amphora_haproxy_rest_driver
            compute_driver = compute_nova_driver
            network_driver = allowed_address_pairs_driver
            loadbalancer_topology = ACTIVE_STANDBY


        để thực hiện cấu hình cho octavia-worker, trong đó:
        - $AMP_IMAGE_ID là image-id amphora đã tạo, image này sẽ được sử dụng để tạo ra amphora instance
        - $AMP_IMAGE_OWNER_ID là image-owner id
        - $AMP_FLAVOR_ID là flavor id được sử dụng để tạo ra amphora instance
        - $AMP_BOOT_NETWORK_LIST là các network id sẽ được sử dụng để tạo ra amphora.
        - $AMP_SECGROUP_LIST là các security group muốn áp dụng cho amphora.
        - ACTIVE_STANDBY: hiện tại có thể có 2 giá trị: `ACTIVE_STANDBY` và `SINGLE` dùng để cấu hình mode cho amphora. Với `ACTIVE_STANDBY` thì load balancer tạo ra sẽ allocate vào 2 amphora lần lượt với role là `master` và `backup`, đối với `SINGLE` thì load balancer tạo ra sẽ chỉ có 1 amphora được allocate.

                [house_keeping]
                spare_amphora_pool_size = 2

        thêm cấu hình trên nếu muốn sử dụng `spare amphora`.

            [oslo_messaging]
            topic = octavia_prov

        để thực hiện cấu hình oslo-message.

            [service_auth]
            project_domain_name = default
            project_name = service
            user_domain_name = default
            password = Welcome123
            username = octavia
            auth_type = password
            auth_url = http://192.168.53.89:5000

        để cấu hình authentication cho user octavia.

            [nova]
            region_name = RegionOne
            endpoint_type = public

            [glance]
            region_name = RegionOne
            endpoint_type = public

            [neutron]
            region_name = RegionOne
            endpoint_type = public

        để cấu hình các endpoint cho phép octavia sử dụng nó để tìm kiếm các thông tin như image, network.

    - Lưu lại file cấu hình vừa chỉnh sửa.
    - Populate database với câu lệnh:

            octavia-db-manage upgrade head
    
    - Restart services:

            service octavia-api restart
            service octavia-housekeeping restart
            service octavia-worker restart
            service octavia-health-manager restart

- ### <a name="test">2.4 Kiểm tra</a>

    - Ta thực hiện tạo một load balancer với câu lệnh đơn giản sau:

            openstack loadbalancer create --name lb1 --vip-subnet-id subnet_id


        trong đó:
        - lb1 là tên của load balancer sẽ được tạo ra.
        - subnet_id là subnet id sẽ cung cấp địa chỉ VIP sử dụng cho load balancer
____

# <a name="content-others">Các nội dung khác</a>
