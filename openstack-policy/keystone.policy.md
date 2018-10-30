- Policy trong Keystone hiện tại đang áp dụng cho 3 loại role:
    - admin
    - owner_project
    - các loại role khác

- Một user được assign role `admin` sẽ có toàn bộ các quyền thao tác.
- Một user không được assign với role `admin` hoặc `owner_project` sẽ chỉ có các thao tác như sau:
    - Show thông tin về username:

            openstack user show myuser
    
        trong đó `myuser` là username được xác thực

    - Show project của user đang được access:

            openstack project list

    - Show role assignment khi cung cấp username là id:

            openstack user show myuser
            +---------------------+----------------------------------+
            | Field               | Value                            |
            +---------------------+----------------------------------+
            | domain_id           | default                          |
            | enabled             | True                             |
            | id                  | 6ac4f2ab2ccb4b3db6023a990ba5a293 |
            | name                | myuser                           |
            | options             | {}                               |
            | password_expires_at | None                             |
            +---------------------+----------------------------------+

            openstack role assignment list --names --user 6ac4f2ab2ccb4b3db6023a990ba5a293
            +---------------+----------------+-------+-----------------------------+--------+--------+-----------+
            | Role          | User           | Group | Project                     | Domain | System | Inherited |
            +---------------+----------------+-------+-----------------------------+--------+--------+-----------+
            | member        | myuser@Default |       | ministry_project_01@Default |        |        | False     |
            | owner_project | myuser@Default |       | myproject@Default           |        |        | False     |
            +---------------+----------------+-------+-----------------------------+--------+--------+-----------+

    - List and check grant role:

            openstack role list --user 6ac4f2ab2ccb4b3db6023a990ba5a293 --project id_project

    - Get token

            openstack token issue

    - Get auth catalog, project, domain, system và credentinal chỉ cho user.

- Một user được assign role `owner_project` sẽ có các quyền như nhũng user được gán các role thông thường. Ngoài ra còn có các thao tác sau:
    - Hiện tại có thể list ra danh sách các user nhưng không filter được theo project:

            openstack user list

    - List role assignment cho một project mà user được assign role `owner_project`:

            openstack role assignment list --names --project 13b3278e6e52499b9155af8acdb763c5
            +---------------+------------------+-------+-----------------------------+--------+--------+-----------+
            | Role          | User             | Group | Project                     | Domain | System | Inherited |
            +---------------+------------------+-------+-----------------------------+--------+--------+-----------+
            | owner_project | ministry@Default |       | ministry_project_01@Default |        |        | False     |
            | member        | myuser@Default   |       | ministry_project_01@Default |        |        | False     |
            | reader        | demo@Default     |       | ministry_project_01@Default |        |        | False     |
            +---------------+------------------+-------+-----------------------------+--------+--------+-----------+
    
    - Add hoặc remove role cho một user khác đối với project mà user đang được assign role `owner_project` với command:

            openstack role add
        &
            openstack role remove

    - Có thể xem các role đang tồn tại với command:

            openstack role list


