# 1. Giới thiệu về Trove

____

# Mục lục
- [1. Chức năng](#feature)
- [2. Các thành phần](#)
    - [2.1 trove-api](#trove-api)
    - [2.2 trove-guestagent](#trove-guestagent)
    - [2.3 trove-taskmanager](#trove-taskmanager)
    - [2.4 trove-conductor](#trove-conductor)
- [Các nội dung khác](#content-others)

____

# <a name="content">Nội dung</a>
- ### <a name="feature">1. Chức năng</a>
    - Là một project trong Openstack cung cấp dịch vụ Database as a Service( DaaS)
    - Nhắm vào mục đích cho phép người dùng tạo ra các loại database một cách nhanh chóng và đơn giản mà không cần quan tâm đến bất kỳ một tác vụ nào thuộc về người quản trị.
    - Người dùng hay người quản trị clouds có thể cung cấp và quản lý nhiều database instances trong các trường hợp cần thiết.
    - Ban đầu, service sẽ chú trọng vào việc cung cấp các tài nguyên isolate với hiệu năng cao cùng với các công việc tự động quản trị phức tập như triển khai, cấu hình, backups, restores hay monitoring.

- ### <a name="">2. Các thành phần</a>
- ### <a name="trove-api">2.1 trove-api</a>
    - Cung cấp RESTful API hỗ trợ JSON và XML để tạo và quản lý Trove instances. Bao gồm:
        + RESTful component
        + Entrypoint (/bin/trove-api)
        + Sử dụng WSGI launcher được cấu hình ở file `/etc/trove/api-paste.ini`

- ### <a name="trove-guestagent">2.2 trove-guestagent</a>
    - Thực hiện cung cấp instances và quản lý vòng đời của instances. Thực hiện vận hành instances.
    - Listen trên RabbitMQ topic
    - Run RPCService được cấu hình ở file `/etc/trove/trove-taskmanager.conf`

- ### <a name="trove-taskmanager">2.3 trove-taskmanager</a>
    - Là service chạy bên trong guest instances ( Database instances) dùng để quản lý và thực hiện các tác vụ trong chính instance đó. Các tác vụ được lấy từ RPCService Topic.
    - GuestAgent chạy trên tất cả các DB Instance, và có một MQ topic riêng dùng cho việc listen. 
    - RPC Service được cấu hình ở file `/etc/trove/trove-guestagent.conf` 
    
- ### <a name="trove-conductor">2.4 trove-conductor</a>
    - Là service thực hiện nhận và cập nhật các status của guestagent thông qua RPC Topic.
____

# <a name="content-others">Các nội dung khác</a>
