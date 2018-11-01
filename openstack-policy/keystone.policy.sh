cat << EOF > /etc/keystone/keystone.policy.json
{
    "admin_required": "role:admin",
    "cloud_admin": "role:admin and (is_admin_project:True or domain_id:admin_domain_id)",
    "service_role": "role:service",
    "service_or_admin": "rule:admin_required or rule:service_role",
    "owner": "user_id:%(user_id)s or user_id:%(target.token.user_id)s",
    "admin_or_owner": "(rule:admin_required and domain_id:%(target.token.user.domain.id)s) or rule:owner",
    "admin_and_matching_domain_id": "rule:admin_required and domain_id:%(domain_id)s",
    "service_admin_or_owner": "rule:service_or_admin or rule:owner",
    "default": "rule:admin_required",

    "admin_and_matching_target_user_domain_id": "rule:admin_required and domain_id:%(target.user.domain_id)s",

    "identity:get_user": "rule:cloud_admin or rule:admin_and_matching_target_user_domain_id or rule:owner or role:owner_project",
    "identity:list_users": "rule:cloud_admin or rule:admin_and_matching_domain_id or role:owner_project",

    "identity:list_roles": "rule:admin_required or role:owner_project",


    "domain_admin_for_grants": "rule:domain_admin_for_global_role_grants or rule:domain_admin_for_domain_role_grants",
    "domain_admin_for_global_role_grants": "rule:admin_required and None:%(target.role.domain_id)s and rule:domain_admin_grant_match",
    "domain_admin_grant_match": "domain_id:%(domain_id)s or domain_id:%(target.project.domain_id)s",
    "domain_admin_for_domain_role_grants": "rule:admin_required and domain_id:%(target.role.domain_id)s and rule:domain_admin_grant_match",
    "project_admin_for_grants": "rule:project_admin_for_global_role_grants or rule:project_admin_for_domain_role_grants",
    "domain_admin_for_list_grants": "rule:admin_required and rule:domain_admin_grant_match",
    "project_admin_for_list_grants": "rule:admin_required and project_id:%(project_id)s",
    "project_admin_for_global_role_grants": "rule:admin_required and None:%(target.role.domain_id)s and project_id:%(project_id)s",
    "project_admin_for_domain_role_grants": "rule:admin_required and project_domain_id:%(target.role.domain_id)s and project_id:%(project_id)s",

    "identity:check_grant": "rule:cloud_admin or rule:domain_admin_for_grants or rule:project_admin_for_grants or (role:owner_project and project_id:%(project_id)s) or rule:owner",
    "identity:list_grants": "rule:cloud_admin or rule:domain_admin_for_list_grants or rule:project_admin_for_list_grants or (role:owner_project and project_id:%(project_id)s) or rule:owner",
    "identity:create_grant": "rule:cloud_admin or rule:domain_admin_for_grants or rule:project_admin_for_grants or (role:owner_project and project_id:%(project_id)s)",
    "identity:revoke_grant": "rule:cloud_admin or rule:domain_admin_for_grants or rule:project_admin_for_grants or (role:owner_project and project_id:%(project_id)s)",

    "admin_on_domain_filter": "rule:admin_required and domain_id:%(scope.domain.id)s",
    "admin_on_project_filter": "rule:admin_required and project_id:%(scope.project.id)s",
    "identity:list_role_assignments": "rule:cloud_admin or rule:admin_on_domain_filter or rule:admin_on_project_filter or (role:owner_project and project_id:%(scope.project.id)s) or user_id:%(user.id)s"

}

EOF



