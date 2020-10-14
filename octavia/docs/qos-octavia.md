# 7. Cấu hình QoS cho Load Balancer.

____

# Mục lục


- [7.1 Giới thiệu](#about)
- [7.2 Cách cấu hình](#confìg)
- [7.3 Kiểm tra](#check)
- [Các nội dung khác](#content-others)

____

# <a name="content">Nội dung</a>

- ### <a name="about">7.1 Giới thiệu</a>
    - Việc thực hiện cấu hình QoS cho load balancer sử dụng QoS Policy Network trong Neutron. Được thực hiện khi ta muốn giới hạn băng thông truy cập tới load balancer. Vì vậy mà ta có thể giới hạn lưu lượng truy cập đến load balancer hoặc ngược lại.
    - Các giới hạn sẽ được áp dụng cho địa chỉ VIP.


- ### <a name="confìg">7.2 Cách cấu hình</a>
    - Giả sử, ta sẽ giới hạn băng thông cho VIP như sau:
        - Max Kbps: 512
        - Max Burst Kbits: 512

    - Các bước thực hiện như sau:
        1. Tạo QoS Policy:

                openstack network qos policy create qos-policy-bandwidth

        2. Tạo QoS Rule:

                openstack network qos rule create --type bandwidth_limit --max-kbps 1024 --max-burst-kbits 1024 qos-policy-bandwidth

        3. Tạo load balancer sử dụng QoS với option là `--vip-qos-policy-id`:

                openstack loadbalancer create --name lb1 --vip-subnet-id public-subnet --vip-qos-policy-id qos-policy-bandwidth
        

- ### <a name="check">7.3 Kiểm tra</a>
    - Việc kiểm tra kết quả sẽ sử dụng công cụ `iperf` listen port 5001. iperf server được chạy trên các backend sau load balancer.
    - Ta cần tạo một listener để có thể truy cập tới port 5001.
    - Trong backend, ta chạy iperf với câu lệnh sau:

            iperf -s
    
    - Từ một client bất kỳ, ta truy cập tới backend thông qua địa chỉ VIP và địa chỉ thật của backend để kiểm tra kết quả. So sánh 2 kết quả, ta nhận thấy tốc độ có thay đổi.
    - Sau khi set `--vip-qos-policy-id None` và kiểm tra với iperf rồi so sánh, ta cũng được kết quả tốc độ đã được giới hạn bởi qos policy.

____

# <a name="content-others">Các nội dung khác</a>
