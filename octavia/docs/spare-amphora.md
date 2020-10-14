# 5. Tính năng spare amphora trong Octavia

____

# Mục lục


- [5.1 Spare Amphora là gì?](#whatis)
- [5.2 Sử dụng spare amphora trong Octavia](#in-use)
- [5.3 Kiểm tra load balancer failover](#in-failover)
- [5.4 Kiểm tra khi một amphora của load balancer bị lỗi](#in-fail)
- [Các nội dung khác](#content-others)

____

# <a name="content">Nội dung</a>

- ### <a name="whatis">5.1 Spare Amphora là gì?</a>
  - Spare amphora là một khái niệm chỉ về tính chất của một amphora trong Octavia service. Theo đó thì amphora được tạo ra sẽ được dùng cho việc đề phòng cho các trường hợp khi một hay nhiều amphora bị lỗi. Các spare amphora sẵn có sẽ được sử dụng ngay sau đó để thay thế cho các amphora bị lỗi và làm giảm quá trình trình downtime đáng kể.


- ### <a name="in-use">5.2 Sử dụng spare amphora trong Octavia</a>
  - Để sử dụng spare trong amphora, ta cần phải thực hiện chỉnh sửa file cấu hình của octavia service (thường là /etc/octavia/octavia.conf ) như sau:

        [house_keeping]
        spare_amphora_pool_size = pool_size

    trong đó pool_size là số lượng mà spare amphora được tạo ra.

  - Lưu lại file cấu hình vừa chỉnh sửa và restart lại service octavia-housekeeping:

        service octavia-housekeeping restart
    

- ### <a name="in-failover">5.3 Kiểm tra load balancer failover</a>
  - Lưu ý: Việc kiểm tra này thực hiện với cấu hình “spare_amphora_pool_size = 2”
  - Sau khi restart service, sau một khoảng thời gian, ta kiểm tra bằng việc thực hiện câu lệnh:

        openstack loadbalancer amphora list

    kết quả nhận được sẽ hiển thị tương tự như sau:

        +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+
        | id                                   | loadbalancer_id                      | status    | role   | lb_network_ip | ha_ip         |
        +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+
        | 27960e8d-57ac-4f88-af2c-ca794ef0ad28 | None                                 | READY     | None   | 192.168.89.16 | None          |
        | c8ab6acf-76f7-4be9-a1c4-1cc9292f0961 | None                                 | READY     | None   | 192.168.89.14 | None          |
        +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+

    Sau khi ta tạo ra một loabalancer:

        +---------------------+--------------------------------------+
        | Field               | Value                                |
        +---------------------+--------------------------------------+
        | admin_state_up      | True                                 |
        | created_at          | 2018-12-20T09:09:08                  |
        | description         |                                      |
        | flavor              |                                      |
        | id                  | 2089cde4-7674-4427-8f79-b6d6f9fda7ea |
        | listeners           |                                      |
        | name                | lb1                                  |
        | operating_status    | ONLINE                               |
        | pools               |                                      |
        | project_id          | aa19bd74317b4ad2a5a14462ba25a056     |
        | provider            | amphora                              |
        | provisioning_status | ACTIVE                               |
        | updated_at          | 2018-12-20T09:59:39                  |
        | vip_address         | 192.168.58.28                        |
        | vip_network_id      | d61ffeb5-edda-430e-8db5-c750787ffe50 |
        | vip_port_id         | 5eb73c4a-e613-4602-9f0c-5361878afcd8 |
        | vip_qos_policy_id   | None                                 |
        | vip_subnet_id       | 4c1208f7-e81c-41a1-852a-5132278fb191 |
        +---------------------+--------------------------------------+

    khi ta thực hiện câu lệnh:

        openstack loadbalancer amphora list

    kết quả thu được tương tự như sau:

        +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+
        | id                                   | loadbalancer_id                      | status    | role   | lb_network_ip | ha_ip         |
        +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+
        | 496ad342-3fbb-4527-9c01-c6b8eb928d7a | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED | BACKUP | 192.168.89.30 | 192.168.58.28 |
        | 981a05f3-a0a9-40d1-8849-fc69fa4b455a | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED | MASTER | 192.168.89.13 | 192.168.58.28 |
        | 27960e8d-57ac-4f88-af2c-ca794ef0ad28 | None                                 | READY     | None   | 192.168.89.16 | None          |
        | c8ab6acf-76f7-4be9-a1c4-1cc9292f0961 | None                                 | READY     | None   | 192.168.89.14 | None          |
        +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+

    Tiếp theo, để kiểm tra về spare amphora có hoạt động hay không, ta sử thực hiện failover cho load balancer sẵn có (ở đây là 2089cde4-7674-4427-8f79-b6d6f9fda7ea )

        openstack loadbalancer failover 2089cde4-7674-4427-8f79-b6d6f9fda7ea
    
    kết quả được kiểm tra nhanh như sau:

        openstack loadbalancer amphora list 
        +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+
        | id                                   | loadbalancer_id                      | status    | role   | lb_network_ip | ha_ip         |
        +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+
        | 496ad342-3fbb-4527-9c01-c6b8eb928d7a | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED | BACKUP | 192.168.89.30 | 192.168.58.28 |
        | 981a05f3-a0a9-40d1-8849-fc69fa4b455a | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED | MASTER | 192.168.89.13 | 192.168.58.28 |
        | 27960e8d-57ac-4f88-af2c-ca794ef0ad28 | None                                 | READY     | None   | 192.168.89.16 | None          |
        | c8ab6acf-76f7-4be9-a1c4-1cc9292f0961 | None                                 | READY     | None   | 192.168.89.14 | None          |
        +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+

        openstack loadbalancer amphora list
        +--------------------------------------+--------------------------------------+-----------+------------+---------------+---------------+
        | id                                   | loadbalancer_id                      | status    | role       | lb_network_ip | ha_ip         |
        +--------------------------------------+--------------------------------------+-----------+------------+---------------+---------------+
        | 981a05f3-a0a9-40d1-8849-fc69fa4b455a | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED | MASTER     | 192.168.89.13 | 192.168.58.28 |
        | 27960e8d-57ac-4f88-af2c-ca794ef0ad28 | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED | STANDALONE | 192.168.89.16 | 192.168.58.28 |
        | c8ab6acf-76f7-4be9-a1c4-1cc9292f0961 | None                                 | READY     | None       | 192.168.89.14 | None          |
        +--------------------------------------+--------------------------------------+-----------+------------+---------------+---------------+

        openstack loadbalancer amphora list
        +--------------------------------------+--------------------------------------+----------------+--------+---------------+---------------+
        | id                                   | loadbalancer_id                      | status         | role   | lb_network_ip | ha_ip         |
        +--------------------------------------+--------------------------------------+----------------+--------+---------------+---------------+
        | 981a05f3-a0a9-40d1-8849-fc69fa4b455a | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | PENDING_DELETE | MASTER | 192.168.89.13 | 192.168.58.28 |
        | 27960e8d-57ac-4f88-af2c-ca794ef0ad28 | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED      | BACKUP | 192.168.89.16 | 192.168.58.28 |
        | c8ab6acf-76f7-4be9-a1c4-1cc9292f0961 | None                                 | READY          | None   | 192.168.89.14 | None          |
        +--------------------------------------+--------------------------------------+----------------+--------+---------------+---------------+

        openstack loadbalancer amphora list
        +--------------------------------------+--------------------------------------+----------------+------------+---------------+---------------+
        | id                                   | loadbalancer_id                      | status         | role       | lb_network_ip | ha_ip         |
        +--------------------------------------+--------------------------------------+----------------+------------+---------------+---------------+
        | 27960e8d-57ac-4f88-af2c-ca794ef0ad28 | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED      | BACKUP     | 192.168.89.16 | 192.168.58.28 |
        | c8ab6acf-76f7-4be9-a1c4-1cc9292f0961 | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED      | STANDALONE | 192.168.89.14 | 192.168.58.28 |
        | 74577538-b43f-4688-adc6-a01321b68d47 | None                                 | PENDING_CREATE | None       | None          | None          |
        | fc097060-4caf-4f93-bc36-cd1b7caa1247 | None                                 | PENDING_CREATE | None       | None          | None          |
        +--------------------------------------+--------------------------------------+----------------+------------+---------------+---------------+

        openstack loadbalancer amphora list
        +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+
        | id                                   | loadbalancer_id                      | status    | role   | lb_network_ip | ha_ip         |
        +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+
        | 27960e8d-57ac-4f88-af2c-ca794ef0ad28 | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED | BACKUP | 192.168.89.16 | 192.168.58.28 |
        | c8ab6acf-76f7-4be9-a1c4-1cc9292f0961 | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED | MASTER | 192.168.89.14 | 192.168.58.28 |
        | 74577538-b43f-4688-adc6-a01321b68d47 | None                                 | BOOTING   | None   | None          | None          |
        | fc097060-4caf-4f93-bc36-cd1b7caa1247 | None                                 | BOOTING   | None   | None          | None          |
        +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+

        openstack loadbalancer amphora list
        +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+
        | id                                   | loadbalancer_id                      | status    | role   | lb_network_ip | ha_ip         |
        +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+
        | 27960e8d-57ac-4f88-af2c-ca794ef0ad28 | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED | BACKUP | 192.168.89.16 | 192.168.58.28 |
        | c8ab6acf-76f7-4be9-a1c4-1cc9292f0961 | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED | MASTER | 192.168.89.14 | 192.168.58.28 |
        | 74577538-b43f-4688-adc6-a01321b68d47 | None                                 | READY     | None   | 192.168.89.25 | None          |
        | fc097060-4caf-4f93-bc36-cd1b7caa1247 | None                                 | READY     | None   | 192.168.89.36 | None          |
        +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+

    Như vậy, các amphora cũ của load balancer (2089cde4-7674-4427-8f79-b6d6f9fda7ea ) đã được thay thế bằng các spare_amphora sẵn có.

- ### <a name="in-fail">5.4 Kiểm tra khi một amphora của load balancer bị lỗi</a>
    - Với kết quả như trên, hiện ta đang có như sau:

            openstack loadbalancer amphora list
            +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+
            | id                                   | loadbalancer_id                      | status    | role   | lb_network_ip | ha_ip         |
            +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+
            | 27960e8d-57ac-4f88-af2c-ca794ef0ad28 | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED | BACKUP | 192.168.89.16 | 192.168.58.28 |
            | c8ab6acf-76f7-4be9-a1c4-1cc9292f0961 | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED | MASTER | 192.168.89.14 | 192.168.58.28 |
            | 74577538-b43f-4688-adc6-a01321b68d47 | None                                 | READY     | None   | 192.168.89.25 | None          |
            | fc097060-4caf-4f93-bc36-cd1b7caa1247 | None                                 | READY     | None   | 192.168.89.36 | None          |
            +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+

        Giả sử, ta sẽ thực hiện xóa đi instance của amphora với role là MASTER hiện có:

            openstack server delete amphora-c8ab6acf-76f7-4be9-a1c4-1cc9292f0961

            openstack loadbalancer amphora list
            +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+
            | id                                   | loadbalancer_id                      | status    | role   | lb_network_ip | ha_ip         |
            +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+
            | 27960e8d-57ac-4f88-af2c-ca794ef0ad28 | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED | BACKUP | 192.168.89.16 | 192.168.58.28 |
            | c8ab6acf-76f7-4be9-a1c4-1cc9292f0961 | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED | MASTER | 192.168.89.14 | 192.168.58.28 |
            | 74577538-b43f-4688-adc6-a01321b68d47 | None                                 | READY     | None   | 192.168.89.25 | None          |
            | fc097060-4caf-4f93-bc36-cd1b7caa1247 | None                                 | READY     | None   | 192.168.89.36 | None          |
            +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+

            openstack loadbalancer amphora list
            +--------------------------------------+--------------------------------------+----------------+--------+---------------+---------------+
            | id                                   | loadbalancer_id                      | status         | role   | lb_network_ip | ha_ip         |
            +--------------------------------------+--------------------------------------+----------------+--------+---------------+---------------+
            | 27960e8d-57ac-4f88-af2c-ca794ef0ad28 | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED      | BACKUP | 192.168.89.16 | 192.168.58.28 |
            | c8ab6acf-76f7-4be9-a1c4-1cc9292f0961 | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | PENDING_DELETE | MASTER | 192.168.89.14 | 192.168.58.28 |
            | 74577538-b43f-4688-adc6-a01321b68d47 | None                                 | READY          | None   | 192.168.89.25 | None          |
            | fc097060-4caf-4f93-bc36-cd1b7caa1247 | None                                 | READY          | None   | 192.168.89.36 | None          |
            +--------------------------------------+--------------------------------------+----------------+--------+---------------+---------------+

            openstack loadbalancer amphora list
            +--------------------------------------+--------------------------------------+----------------+------------+---------------+---------------+
            | id                                   | loadbalancer_id                      | status         | role       | lb_network_ip | ha_ip         |
            +--------------------------------------+--------------------------------------+----------------+------------+---------------+---------------+
            | 27960e8d-57ac-4f88-af2c-ca794ef0ad28 | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED      | BACKUP     | 192.168.89.16 | 192.168.58.28 |
            | 74577538-b43f-4688-adc6-a01321b68d47 | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED      | STANDALONE | 192.168.89.25 | 192.168.58.28 |
            | fc097060-4caf-4f93-bc36-cd1b7caa1247 | None                                 | READY          | None       | 192.168.89.36 | None          |
            | 98c93257-a5bf-4395-9894-0b23f1fac67e | None                                 | PENDING_CREATE | None       | None          | None          |
            +--------------------------------------+--------------------------------------+----------------+------------+---------------+---------------+

            openstack loadbalancer amphora list
            +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+
            | id                                   | loadbalancer_id                      | status    | role   | lb_network_ip | ha_ip         |
            +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+
            | 27960e8d-57ac-4f88-af2c-ca794ef0ad28 | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED | BACKUP | 192.168.89.16 | 192.168.58.28 |
            | 74577538-b43f-4688-adc6-a01321b68d47 | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED | MASTER | 192.168.89.25 | 192.168.58.28 |
            | fc097060-4caf-4f93-bc36-cd1b7caa1247 | None                                 | READY     | None   | 192.168.89.36 | None          |
            | 98c93257-a5bf-4395-9894-0b23f1fac67e | None                                 | BOOTING   | None   | None          | None          |
            +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+

            openstack loadbalancer amphora list
            +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+
            | id                                   | loadbalancer_id                      | status    | role   | lb_network_ip | ha_ip         |
            +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+
            | 27960e8d-57ac-4f88-af2c-ca794ef0ad28 | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED | BACKUP | 192.168.89.16 | 192.168.58.28 |
            | 74577538-b43f-4688-adc6-a01321b68d47 | 2089cde4-7674-4427-8f79-b6d6f9fda7ea | ALLOCATED | MASTER | 192.168.89.25 | 192.168.58.28 |
            | fc097060-4caf-4f93-bc36-cd1b7caa1247 | None                                 | READY     | None   | 192.168.89.36 | None          |
            | 98c93257-a5bf-4395-9894-0b23f1fac67e | None                                 | READY     | None   | 192.168.89.34 | None          |
            +--------------------------------------+--------------------------------------+-----------+--------+---------------+---------------+

        kết quả của việc thay thế giữa amphora error và spare amphora nhanh hay chậm là phụ thuộc vào cấu hình cho octavia-health-manger.

    - Như vậy, ta thấy rằng spare amphora đã làm đúng trách nhiệm của nó.
____

# <a name="content-others">Các nội dung khác</a>
