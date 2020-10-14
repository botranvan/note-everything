# Load Balancer with topology Active - Active



# Nội dung
- [1. Giới thiệu](#about)
- [2. Thử nghiệm](#install)
- [3. Kiểm tra](#checking)




### 1. Giới thiệu
Thử nghiệm tính năng tạo Load Balancer với topology ACTIVE_ACTIVE
Source Code: https://github.com/botranvan/octavia
Openstack Version: Rocky

#### Mô hình



### 2. Thử nghiệm
Yêu cầu: 2 network là External-Network-Trunking và LB-Mgmt-Network có cùng address scope.

```Thực hiện với user admin role```
a. Chuẩn bị:
- Tạo address scope với command:
    ```bash
    openstack address scope create --share --ip-version 4 bgp
    ```
    kết quả nhận được:
    ```bash
    +------------+--------------------------------------+
    | Field      | Value                                |
    +------------+--------------------------------------+
    | headers    |                                      |
    | id         | f71c958f-dbe8-49a2-8fb9-19c5f52a37f1 |
    | ip_version | 4                                    |
    | name       | bgp                                  |
    | project_id | 86acdbd1d72745fd8e8320edd7543400     |
    | shared     | True                                 |
    +------------+--------------------------------------+
    ```

- Tạo subnet pool sử dụng addres scope vừa tạo ở trên. Ví dụ:
    - Cho External-Network-Trunking:
        ```bash
        openstack subnet pool create --address-scope bgp --pool-prefix 192.168.56.0/24 --pool-prefix 192.168.57.0/24 --pool-prefix 192.168.58.0/24 EXT_DIRECTNET
        ```
    - Cho LB-Mgmt-Network:
        ```bash
        openstack subnet pool create --address-scope bgp --pool-prefix 192.0.2.0/20 --pool-prefix 192.0.2.128/20 --pool-prefix 192.0.8.0/21 --pool-prefix 192.0.9.0/22 --pool-prefix 192.89.0.0/19 dev-lb-mgmt-net
        ```
    

### 3. Kiểm tra
