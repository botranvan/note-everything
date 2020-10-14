# 3. Sử dụng L7 Policy trong Octavia.

____

# Mục lục


- [3.1 Giới thiệu về L7 Policy](#about)
- [3.2 Cách tạo và sử dụng L7 Policy để chuyển hướng request](#in-use)
    - [3.2.1 Chuyển hướng request tới URL](#REDIRECT_TO_URL)
    - [3.2.2 Chuyển hướng request tới POOL](#REDIRECT_TO_POOL)
- [3.3 Tạo L7 Policy để chặn các truy cập](#REJECT)
- [Các nội dung khác](#content-others)

____

# <a name="content">Nội dung</a>

- ### <a name="about">3.1 Giới thiệu về L7 Policy</a>
    - L7 Policy (Layer 7 Policy) trong Octavia được sử dụng để kiểm soát các request từ client đến các `listener` trong một load balancer.
    - Các action của một L7 Policy bao gồm:
        - REJECT: Request mà match với Policy sẽ bị chặn (block)
        - REDIRECT_TO_URL: Request mà match với policy sẽ được chuyển hướng tới giá trị một url khác.
        - REDIRECT_TO_POOL: Request mà match với policy sẽ được chuyển hướng tới một pool được chỉ định. 

- ### <a name="in-use">3.2 Cách tạo và sử dụng L7 Policy</a>
    Trong phiên bản Octavia hiện tại, các request gửi tới load balancer có thể được chuyển hướng tới một địa chỉ khác hoặc chuyển hướng đến một pool khác nằm trong load balancer đó.

    - ##### <a name='REDIRECT_TO_URL'>3.2.1 Chuyển hướng request tới URL</a>
        - Ví dụ, khi có một client thực hiện truy cập đến địa chỉ `http://example.com` nhưng ta lại muốn khách hàng truy cập tới `https://example.com`. Như vậy, ta có thể sử dụng L7 policy với action là `REDIRECT_TO_URL` để có thể làm việc đó.
        - Các bước thực hiện tạo ra một L7 Policy đó là:
            1. Tạo load balancer
            2. Tạo listener
            3. Tạo L7 Policy cho listener

        - Chi tiết thực hiện các như sau:
            tạo load balancer:

                openstack loadbalancer create --name lb1 --vip-subnet-id subnet_id
            
            trong đó:
            - subnet_id là id của network sẽ được sử dụng để tạo ra VIP.

            tạo listener:

                openstack loadbalancer listener create --name http_listener --protocol HTTP --protocol-port 80 lb1

            tạo L7 Policy:

                openstack loadbalancer l7policy create --action REDIRECT_TO_URL --redirect-url https://www.example.com/ --name policy1 http_listener

            tạo L7 rule:

                openstack loadbalancer l7rule create --compare-type STARTS_WITH --type PATH --value / policy1

    - ##### <a name='REDIRECT_TO_POOL'>3.2.2 Chuyển hướng request tới POOL</a>
        - Lưu ý: Các pool có thể chuyển hướng phải nằm cùng trên cùng một load balancer.
        - Giả sử việc thực hiện sẽ chuyển hướng các request /js /css tới pool là static_resouces, điều này được sử dụng khi các tài nguyên nằm trên các server khác nhau. Ta cần tạo ra L7 với action là `REDIRECT_TO_POOL` như sau:

                openstack loadbalancer l7policy create --action REDIRECT_TO_POOL --redirect-pool static_resouces --name policy2 listener1
                openstack loadbalancer l7rule create --compare-type STARTS_WITH --type PATH --value /js policy2
                openstack loadbalancer l7rule create --compare-type STARTS_WITH --type PATH --value /css policy2

- ### <a name="REJECT">3.3 Tạo L7 Policy để chặn các truy cập</a>
    - Ngữ cảnh sử dụng Policy này là khi ta không muốn client thực hiện truy cập tới một đường dẫn nào đó hoặc đường dẫn có chứa các ký tự đặc biệt chẳng hạn như "GET https://example.com/?username=admin" thì ta có thể tạo một L7 Policy với action là `REJECT`.

            openstack loadalancer l7policy create --action REJECT --name policy3 http_listener
        
        sau đó là tạo L7 rule:

            openstack loadbalancer l7rule create --compare-type STARTS_WITH --type PATH --value /admin policy3 

        
____

# <a name="content-others">Các nội dung khác</a>
