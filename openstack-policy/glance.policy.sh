cat << EOF > /etc/glance/policy.json
{
    "context_is_admin":  "role:admin",
    "default": "role:admin",

    # edited
    "add_image": "rule:context_is_admin",

    # edited
    "delete_image": "rule:context_is_admin",

    "get_image": "",
    "get_images": "",

    # edited
    "modify_image": "rule:context_is_admin",

    "publicize_image": "role:admin",

    # edited
    "communitize_image": "rule:context_is_admin",

    # edited
    "copy_from": "rule:context_is_admin",


    "download_image": "",

    # edited
    "upload_image": "rule:context_is_admin",

    "delete_image_location": "",
    "get_image_location": "",
    "set_image_location": "",

    # edited
    "add_member": "rule:context_is_admin",

    # edited
    "delete_member": "rule:context_is_admin",

    "get_member": "",
    "get_members": "",

    # edited
    "modify_member": "rule:context_is_admin",


    "manage_image_cache": "role:admin",

    "get_task": "",
    "get_tasks": "",

    # edited
    "add_task": "rule:context_is_admin",

    # edited
    "modify_task": "rule:context_is_admin",

    "tasks_api_access": "role:admin",

    "deactivate": "",
    "reactivate": "",

    "get_metadef_namespace": "",
    "get_metadef_namespaces":"",

    # edited
    "modify_metadef_namespace":"rule:context_is_admin",

    # edited
    "add_metadef_namespace":"rule:context_is_admin",


    "get_metadef_object":"",
    "get_metadef_objects":"",

    # edited
    "modify_metadef_object":"rule:context_is_admin",

    "add_metadef_object":"",

    "list_metadef_resource_types":"",
    "get_metadef_resource_type":"",

    # edited
    "add_metadef_resource_type_association":"rule:context_is_admin",


    "get_metadef_property":"",
    "get_metadef_properties":"",

    # edited
    "modify_metadef_property":"rule:context_is_admin",

    # edited
    "add_metadef_property":"rule:context_is_admin",


    "get_metadef_tag":"",
    "get_metadef_tags":"",

    # edited
    "modify_metadef_tag":"rule:context_is_admin",

    # edited
    "add_metadef_tag":"rule:context_is_admin",

    # edited
    "add_metadef_tags":"rule:context_is_admin"


}

EOF


