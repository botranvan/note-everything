# Backup và Restore cho database instances

____

# Mục lục


- [1. Backup](#backup)
- [2. Restore](#restore)
- [Các nội dung khác](#content-others)

____

# <a name="content">Nội dung</a>

- Yêu cầu thực hiện:
	+ Đang có một instances database(stand-alone) hoạt động bình thường.
	+ Openstack phải được cài đặt và sử dụng Swift Storage.

- ### <a name="backup">1. Backup</a>
	- Để tạo backup, ta thực hiện sử dụng câu lệnh với cú pháp như sau:

			trove backup-create INSTANCE_ID backup1

		trong đó:
		- INSTANCE_ID là `id` của database instance cần được backup. ID này lấy được từ command `trove list` hoặc `openstack database list instance`.
		- backup1 là tên của backup sẽ được tạo ra.
	
	- Ví dụ:

		+ Lấy id của instances:

				trove list
				+--------------------------------------+--------+-----------+-------------------+--------+-----------+------+
				|                  id                  |  name  | datastore | datastore_version | status | flavor_id | size |
				+--------------------------------------+--------+-----------+-------------------+--------+-----------+------+
				| 97b4b853-80f6-414f-ba6f-c6f455a79ae6 | guest1 |   mysql   |     mysql-5.5     | ACTIVE |     10    |  2   |
				+--------------------------------------+--------+-----------+-------------------+--------+-----------+------+
		
		+ Tạo backup cho instances với id là `97b4b853-80f6-414f-ba6f-c6f455a79ae6`:

				trove backup-create 97b4b853-80f6-414f-ba6f-c6f455a79ae6 backup1
				+-------------+--------------------------------------+
				|   Property  |                Value                 |
				+-------------+--------------------------------------+
				|   created   |         2018-01-01T17:09:07          |
				| description |                 None                 |
				|      id     | 8af30763-61fd-4aab-8fe8-57d528911138 |
				| instance_id | 97b4b853-80f6-414f-ba6f-c6f455a79ae6 |
				| locationRef |                 None                 |
				|     name    |               backup1                |
				|  parent_id  |                 None                 |
				|     size    |                 None                 |
				|    status   |                 NEW                  |
				|   updated   |         2018-01-01T17:09:07          |
				+-------------+--------------------------------------+

		+ Để liệt kê ra các backup, ta sử dụng câu lệnh sau:

				trove backup-list

- ### <a name="restore">2. Restore</a>

	- Giả định rằng, bạn đã có một bản backup của một database instances nào đó. Ta có thể thực hiện restore database instances với câu lệnh sau:

			trove create guest2 10 --size 2 --backup BACKUP_ID

		việc backup này thực chất là tạo ra một database instance mới và sẽ có nhiệm vụ thay thế cho database instance trước đó. Sau khi sử dụng câu lệnh trên. Ta cần phải xác định database instance backup đã ở trạng thái ACTIVE hay chưa với câu lệnh:

			trove list
			+-----------+--------+-----------+-------------------+--------+-----------+------+
			|     id    |  name  | datastore | datastore_version | status | flavor_id | size |
			+-----------+--------+-----------+-------------------+--------+-----------+------+
			| 97b...ae6 | guest1 |   mysql   |     mysql-5.5     | ACTIVE |     10    |  2   |
			| ac7...04b | guest2 |   mysql   |     mysql-5.5     | ACTIVE |     10    |  2   |
			+-----------+--------+-----------+-------------------+--------+-----------+------+

	- Công việc tiếp theo, đó là hãy kiểm tra lại dữ liệu của databse trong instances backup vừa tạo (ở đây là guest2) chẳng hạn như các user, các database, .. với câu lệnh:

		+ Kiểm tra database:

				trove database-list INSTANCE_ID
				+--------------------+
				|        name        |
				+--------------------+
				|        db1         |
				|        db2         |
				| performance_schema |
				|        test        |
				+--------------------+

		+ Kiểm tra user:

				trove user-list INSTANCE_ID
				+--------+------+-----------+
				|  name  | host | databases |
				+--------+------+-----------+
				| user1  |  %   |  db1, db2 |
				+--------+------+-----------+

		+ Sau khi kiểm tra lại dữ liệu đã đầy đủ. Thực hiện cung cấp truy cập cho user tới instances và xóa instances cũ.

				trove delete INSTANCE_ID
____

# <a name="content-others">Các nội dung khác</a>
