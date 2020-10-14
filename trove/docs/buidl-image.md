# Build Trove Guest Agent Images

____

# Mục lục

- [1. Mô tả chung](#about)
- [2. Cách build](#build)
- [3. Cách sử dụng](#used)
- [Các nội dung khác](#content-others)

____

# <a name="content">Nội dung</a>

- ### <a name="about">1. Mô tả chung</a>
    - Việc build image sử dụng công cụ [diskimage-builder](https://github.com/openstack/diskimage-builder).
    - Công cụ trên sử dụng các elements (thực tế có thể coi như là bash-scripts) để cài đặt. bằng việc chỉ định tới chúng qua một biến môi trường là `ELEMENTS_PATH`. Ví dụ, ta có thể khai báo như sau:

            export ELEMENTS_PATH="/opt/stack/diskimage-builder/diskimage_builder/elements"
            export ELEMENTS_PATH+=":/opt/stack/trove/integration/scripts/files/elements"

        để có thể biết về chi tiết việc sử dụng của các biến môi trường. Ta cần phải đọc elements mà ta sử dụng để build images.

    - Tóm lại để build ra các image đáp ứng nhu cầu của chúng ta, ta cần phải tìm hiểu về các elements mà ta sử dụng.

            
- ### <a name="build">2. Cách build</a>
    - Đây là mẫu câu lệnh chung nhất để tạo ra một image sử dụng cho trove. Ví dụ như sau:

            export CONTROLLER_IP=192.168.53.89
            export ELEMENTS_PATH="/opt/stack/diskimage-builder/diskimage_builder/elements"
            export ELEMENTS_PATH+=":/opt/stack/trove/integration/scripts/files/elements"
            export TROVESTACK_SCRIPTS="/opt/stack/trove/integration/scripts"
            export GUEST_USERNAME=ministry
            export HOST_USERNAME=stack
            export HOST_SCP_USERNAME=stack
            export OS_NAME=ubuntu
            export RELEASE=xenial
            export DIB_RELEASE=bionic
            export OPS_REPOS_NAME=cloud-archive:queens
            export SERVICE_TYPE=mongodb
            export SSH_DIR="/opt/stack/.ssh"
            # in /opt/stack run command:
            # mkdir .ssh && chmod 700 .ssh
            # ssh-keygen -b 2048 -t rsa
            # cat id_rsa.pub >> authorized_keys
            export DIB_APT_CONF_DIR=/etc/apt/apt.conf.d
            export DIB_CLOUD_INIT_ETC_HOSTS=true
            export DIB_CLOUD_INIT_DATASOURCES="ConfigDrive"
            # export DATASTORE_PKG_LOCATION=mysql-community-server_5.7.24-1ubuntu16.04_amd64.deb

            disk-image-create -a amd64 -o ${OS_NAME}-${RELEASE}-${SERVICE_TYPE} vm ${OS_NAME} ${OS_NAME}-guest cloud-init-datasources ${OS_NAME}-${SERVICE_TYPE} ${OS_NAME}-${RELEASE}-${SERVICE_TYPE} -p trove-guestagent

- ### <a name="used">3. Cách sử dụng</a>
    - Sau khi tạo ra images và upload images đó tới openstack glance. Ta cần phải tạo ra các flavor với yêu cầu có thể đáp ứng là làm sao cho service database bên trong guest-images có thể chạy được.
    - Việc tiếp theo, ta cần tạo ra `datastore` - đại điện cho mỗi loại database mà ta sẽ sử dụng, chúng được sử dụng để truy cập tới các thông tin liên quan đến database như các cấu hình dành riêng, images, plugins... như sau:

            su -s /bin/sh -c "trove-manage \
              --config-file /etc/trove/trove.conf \
              datastore_update mysql ''" trove
        
        trong đó `mysql` là tên của `datastore`, datastore có thể có các giá trị sau:
        - cassandra
        - couchbase
        - couchdb
        - db2
        - mariadb
        - mongodb
        - mysql
        - percona
        - postgresql
        - pxc
        - redis
        - vertica

    - Thực hiện gán datastore sử dụng images mà ta đã tạo với câu lệnh sau:

            trove-manage --config-file=/etc/trove/trove.conf datastore_version_update mongodb mongodb-3.2 mongodb GLANCE_ID "" 1

        trong đó:
        - GLANCE_ID: là id của image sẽ được sử dụng để tạo ra database instances.
        - mongodb: lần lượt là tên của datastore, manager
        - mongodb-3.2: (default version) chỉ ra phiên bản của database và nó sẽ được đi liền với image này.
        - "": chỉ ra package yêu cầu được cài đặt trong guest images.
        - 1: chỉ ra trạng thái active của datastore version. (Giá trị 0 là deactive)
    
    - Tới thời điểm này, ta có thể tạo ra được các database với subcommands của `openstack database` hoặc c Ví dụ:

            openstack database instance create \
            --volume_type ceph --size 5 --nic net-id=6aef82ad-95e6-45d5-b0bc-799ab28da296 \
            --databases myDB --users myDB.userA:password \
            --datastore_version xenial-mongodb-3.2.11 --datastore mongodb \
            xenial-mongodb-3.2.11-instance-1 6ffc31bf-0407-4b40-954b-f22857cf2f83

        với câu lệnh trên, ta đã thực hiện tạo ra một instance database là myDB có một user được tạo kèm là `userA` với password là `password` và có thể truy cập qua IP của network có ID là `6aef82ad-95e6-45d5-b0bc-799ab28da296`.
        Lưu ý rằng: riêng đối với database là mongodb, ta cần phải tạo user có dạng như sau: db_name.user_name. Các loại database khác tạo bình thường. Ví dụ:

            openstack database instance create \
            --volume_type ceph --size 5 --nic net-id=6aef82ad-95e6-45d5-b0bc-799ab28da296 \
            --databases myDB --users userA:password \
            --datastore_version postgresql-9.6 --datastore postgresql \
            xenial-postgresql-9.6-instance-1 b0bbd3ed-167c-4fe9-b7e4-d708dc167c98
            
____
# <a name="content-others">Các nội dung khác</a>
