# 4. Thực hiện tạo ra amphora instance với các flavor khác nhau.

____

# Mục lục


- [4.1 Giới thiệu](#about)
- [4.2 Cách thực hiện](#config)
- [4.3 Kiểm tra kết quả](#check)
- [Các nội dung khác](#content-others)

____

# <a name="content">Nội dung</a>

- ### <a name="about">4.1 Giới thiệu</a>
    - Bản cập nhật sắp tới của Octavia sẽ cho phép khi tạo ra một load balancer, các amphora instance sẽ được tạo ra theo các flavor compute khác nhau. Việc này đảm bảo tránh cho việc dư thừa, hoặc thiếu các tài nguyên. Giả sử:
        - Ta có nhu cầu tạo ra một load balancer cung cấp cho một dịch vụ có lượng truy cập lớn, đòi hỏi amphora có cấu hình 16 Core và 32Gb RAM và một load balancer cung cấp cho một dịch vụ có lượng truy cập nhỏ chỉ cần amphora có câu shình 1 Core và 512Mb RAM là đủ.
        - Hiện tại, nếu ta sử dụng cấu hình của Octavia với option là `amp_flavor_id` thì không phân biệt nhu cầu sử dụng, các amphora được tạo ra sẽ đều giống nhau và có cùng một cấu hình do thế mà có thể thừa hoặc thiếu tài nguyên cung cấp cho instance gây ra lãng phí. 
        - Việc sử dụng flavor cho phép tạo ra các load balancer với các cấu hình khác nhau mà ta có thể chỉ định được. Nếu không chỉ định flavor khi tạo thì load balancer sẽ được tạo ra với flavor đã được cấu hình mặc định trong file `/etc/octavia/octavia.conf`. (option cấu hình: amp_flavor_id)
        - Cung cấp 2 provider là `amphora` và `octavia` cho load balancer, để xem priovider hỗ trợ, ta sử dụng câu lệnh:

                openstack loadbalancer provider list

            và sử dụng câu lệnh:

                openstack loadbalancer provider capability list provider_name

            để xem các khai báo được sử dụng cho provider đó khi khởi tạo flavor provider.

- ### <a name="config">4.2 Cách thực hiện</a>
    - Để tiện cho quá trình kiểm tra, ta cần có ít nhất là 3 flavor compute khác nhau trong đó một flavor được dùng để cấu hình cho amp_flavor_id (giả sử có `ID: dee8f2d5-d4c3-4e04-8fc8-fdcbfdb32aeb`) và hai flavor còn lại là lần lượt có `ID: 5c661cc8-d02b-4b43-807b-93ce16b5af58` và `ID: 1dd5e05e-84ab-474e-b080-915ad06b09a1`.
    - Tiếp theo, ta cần tạo `load balancer flavor profile`:
        đầu tiên, ta sẽ xem các thông có thể khai báo cho provider được dùng để tạo ra flavor provider với câu lệnh:

            openstack loadbalancer provider capability list provider_name

        giả sử provider_name là octavia, ta sẽ nhận được kết quả như sau:

        ```bash
        +-----------------------+-----------------------------------------------------------------------------------------------------------------------------+
        | name                  | description                                                                                                                 |
        +-----------------------+-----------------------------------------------------------------------------------------------------------------------------+
        | loadbalancer_topology | The load balancer topology. One of: SINGLE - One amphora per load balancer. ACTIVE_STANDBY - Two amphora per load balancer. |
        | compute_flavor        | The compute driver flavor ID.                                                                                               |
        +-----------------------+-----------------------------------------------------------------------------------------------------------------------------+
        ```

        ở đây, ta thấy khi tạo ra flavor profile có thể sử dụng hai giá trị `loadbalancer_topology` và `compute_flavor` để khai báo cấu hình cho flavor profile này.
        Như vậy, để tạo ra một flavor profile ta có thể thực hiện sử dụng câu lệnh như sau:

        ```bash
        openstack loadbalancer flavorprofile create --name amphora-standalone --provider octavia \
        --flavor-data '{"loadbalancer_topology": "SINGLE", "compute_flavor": "1dd5e05e-84ab-474e-b080-915ad06b09a1"}'

        openstack loadbalancer flavorprofile create --name amphora-act-stdby --provider octavia \
        --flavor-data '{"loadbalancer_topology": "ACTIVE_STANDBY", "compute_flavor": "5c661cc8-d02b-4b43-807b-93ce16b5af58"}'
        ```
    
    - Sau khi tạo xong flavor profile, ta cần tạo ra các loadbalancer flavor liên kết với chúng như sau:

        ```bash
        openstack loadbalancer flavor create --name Basic --flavorprofile e0010533-3dc0-452f-a3ec-47d682b68b29

        openstack loadbalancer flavor create --name Business --flavorprofile 8e94232b-8240-4457-a6b8-a7ef97de5fab
        ```

    - Như vậy, ta đã thực hiện, tạo xong các flavor sử dụng cho quá trình tạo load balancer.


- ### <a name="check">4.3 Kiểm tra kết quả</a>
    - Để thực hiện kiểm tra kết quả, ta sử dụng 3 câu lệnh sau:

            curl -X POST -H "Content-Type: application/json" -H "X-Auth-Token: <token>" -d '{"loadbalancer": {"description": "My favorite load balancer", "admin_state_up": true, "project_id": "3603e0083c854e3f9d85a4c082c32350", "vip_subnet_id": "aa46077a-689f-4c26-894c-1fd8d2e035d2", "provider": "octavia", "name": "load_balancer" } }' http://198.51.100.10:9876/v2/lbaas/loadbalancers

            curl -X POST -H "Content-Type: application/json" -H "X-Auth-Token: <token>" -d '{"loadbalancer": {"description": "My favorite load balancer", "admin_state_up": true, "project_id": "3603e0083c854e3f9d85a4c082c32350", "flavor_id": "cd36a280-1e1d-4ee8-bd7f-dfbe23898df4", "vip_subnet_id": "aa46077a-689f-4c26-894c-1fd8d2e035d2", "provider": "octavia", "name": "normal_load_balancer"} }' http://198.51.100.10:9876/v2/lbaas/loadbalancers

            curl -X POST -H "Content-Type: application/json" -H "X-Auth-Token: <token>" -d '{"loadbalancer": {"description": "My favorite load balancer", "admin_state_up": true, "project_id": "3603e0083c854e3f9d85a4c082c32350", "flavor_id": "ffebbcd6-c110-48a9-b4ad-d405e60bc28a", "vip_subnet_id": "aa46077a-689f-4c26-894c-1fd8d2e035d2", "provider": "octavia", "name": "best_load_balancer"} }' http://198.51.100.10:9876/v2/lbaas/loadbalancers

    - Sau đó thực hiện kiểm tra các amphora tương ứng của từng load balancer, ta thấy các amphora được tạo ra theo các flavor riêng biệt.
____

# <a name="content-others">Các nội dung khác</a>
