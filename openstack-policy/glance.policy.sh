cat << EOF > /etc/glance/policy.json
{
    "context_is_admin":  "role:admin",
    "default": "role:admin",

    "add_image": "rule:context_is_admin",
    "delete_image": "rule:context_is_admin",
    "get_image": "",
    "get_images": "",
    "modify_image": "rule:context_is_admin",
    "publicize_image": "role:admin",
    "communitize_image": "rule:context_is_admin",
    "copy_from": "rule:context_is_admin",

    "download_image": "",
    "upload_image": "rule:context_is_admin",

    "delete_image_location": "",
    "get_image_location": "",
    "set_image_location": "",

    "add_member": "rule:context_is_admin",
    "delete_member": "rule:context_is_admin",
    "get_member": "",
    "get_members": "",
    "modify_member": "rule:context_is_admin",

    "manage_image_cache": "role:admin",

    "get_task": "",
    "get_tasks": "",
    "add_task": "rule:context_is_admin",
    "modify_task": "rule:context_is_admin",
    "tasks_api_access": "role:admin",

    "deactivate": "",
    "reactivate": "",

    "get_metadef_namespace": "",
    "get_metadef_namespaces":"",
    "modify_metadef_namespace":"rule:context_is_admin",
    "add_metadef_namespace":"",

    "get_metadef_object":"",
    "get_metadef_objects":"",
    "modify_metadef_object":"rule:context_is_admin",
    "add_metadef_object":"",

    "list_metadef_resource_types":"",
    "get_metadef_resource_type":"",
    "add_metadef_resource_type_association":"rule:context_is_admin",

    "get_metadef_property":"",
    "get_metadef_properties":"",
    "modify_metadef_property":"rule:context_is_admin",
    "add_metadef_property":"rule:context_is_admin",

    "get_metadef_tag":"",
    "get_metadef_tags":"",
    "modify_metadef_tag":"rule:context_is_admin",
    "add_metadef_tag":"rule:context_is_admin",
    "add_metadef_tags":"rule:context_is_admin"

}

EOF



