cat << EOF > /etc/cinder/cinder.policy.yaml
# Custom rules
# edited
"is_owner_project": "role:owner_project and project_id:%(project_id)s"

# edited
"is_member": "role:member and user_id:%(user_id)s and project_id:%(project_id)s"

# edited
"is_owner_or_member": "rule:is_owner_project or rule:is_member"

# edited
"is_reader": "role:reader and project_id:%(project_id)s"

# Decides what is required for the 'is_admin:True' check to succeed.
# edited
"context_is_admin": "role:admin"

# Default rule for most non-Admin APIs.
# edited
"admin_or_owner": "is_admin:True or (role:admin and is_admin_project:True) or rule:is_owner_project"

# Default rule for most Admin APIs.
# edited
"admin_api": "is_admin:True or (role:admin and is_admin_project:True)"



# =============================================================================

# Create attachment.
# POST  /attachments
# edited
"volume:attachment_create": "rule:admin_or_owner or rule:is_member"

# Update attachment.
# PUT  /attachments/{attachment_id}
# edited
"volume:attachment_update": "rule:admin_or_owner or rule:is_member"

# Delete attachment.
# DELETE  /attachments/{attachment_id}
# edited
"volume:attachment_delete": "rule:admin_or_owner or rule:is_member"

# Mark a volume attachment process as completed (in-use)
# POST  /attachments/{attachment_id}/action (os-complete)
# edited
"volume:attachment_complete": "rule:admin_or_owner or rule:is_member"

# Allow multiattach of bootable volumes.
# POST  /attachments
# edited
"volume:multiattach_bootable_volume": "rule:admin_or_owner or rule:is_member"

# List messages.
# GET  /messages
# edited
"message:get_all": "rule:admin_or_owner or rule:is_member or rule:is_reader"

# Show message.
# GET  /messages/{message_id}
# edited
"message:get": "rule:admin_or_owner or rule:is_member or rule:is_reader"

# Delete message.
# DELETE  /messages/{message_id}
# edited
"message:delete": "rule:admin_or_owner or rule:is_member"



# Show snapshot's metadata or one specified metadata with a given key.
# GET  /snapshots/{snapshot_id}/metadata
# GET  /snapshots/{snapshot_id}/metadata/{key}
# edited
"volume:get_snapshot_metadata": "rule:admin_or_owner or rule:is_member or rule:is_reader"

# Update snapshot's metadata or one specified metadata with a given
# key.
# PUT  /snapshots/{snapshot_id}/metadata
# PUT  /snapshots/{snapshot_id}/metadata/{key}
# edited
"volume:update_snapshot_metadata": "rule:admin_or_owner or rule:is_member"

# Delete snapshot's specified metadata with a given key.
# DELETE  /snapshots/{snapshot_id}/metadata/{key}
# edited
"volume:delete_snapshot_metadata": "rule:admin_or_owner or rule:is_member"

# List snapshots.
# GET  /snapshots
# GET  /snapshots/detail
# edited
"volume:get_all_snapshots": "rule:admin_or_owner or rule:is_member or rule:is_reader"

# List snapshots with extended attributes.
# GET  /snapshots
# GET  /snapshots/detail
# edited
"volume_extension:extended_snapshot_attributes": "rule:admin_or_owner or rule:is_member or rule:is_reader"

# Create snapshot.
# POST  /snapshots
# edited
"volume:create_snapshot": "rule:admin_or_owner or rule:is_member"

# Show snapshot.
# GET  /snapshots/{snapshot_id}
# edited
"volume:get_snapshot": "rule:admin_or_owner or rule:is_member or rule:is_reader"

# Update snapshot.
# PUT  /snapshots/{snapshot_id}
# edited
"volume:update_snapshot": "rule:admin_or_owner or rule:is_member"

# Delete snapshot.
# DELETE  /snapshots/{snapshot_id}
# edited
"volume:delete_snapshot": "rule:admin_or_owner or rule:is_member"



# Update database fields of snapshot.
# POST  /snapshots/{snapshot_id}/action (update_snapshot_status)
# edited
"snapshot_extension:snapshot_actions:update_snapshot_status": "rule:admin_or_owner or rule:is_member"







# List backups.
# GET  /backups
# GET  /backups/detail
# edited
"backup:get_all": "rule:admin_or_owner or rule:is_member or rule:is_reader"



# Create backup.
# POST  /backups
# edited
"backup:create": "rule:admin_or_owner or rule:is_member"

# Show backup.
# GET  /backups/{backup_id}
# edited
"backup:get": "rule:admin_or_owner or rule:is_member or rule:is_reader"

# Update backup.
# PUT  /backups/{backup_id}
# edited
"backup:update": "rule:admin_or_owner or rule:is_member"

# Delete backup.
# DELETE  /backups/{backup_id}
# edited
"backup:delete": "rule:admin_or_owner or rule:is_member"

# Restore backup.
# POST  /backups/{backup_id}/restore
# edited
"backup:restore": "rule:admin_or_owner or rule:is_member"









# List groups.
# GET  /groups
# GET  /groups/detail
# edited
"group:get_all": "@"



# Show group.
# GET  /groups/{group_id}
# edited
"group:get": "@"









# List group snapshots.
# GET  /group_snapshots
# GET  /group_snapshots/detail
# edited
"group:get_all_group_snapshots": "rule:admin_or_owner or rule:is_member or rule:is_reader"

# Create group snapshot.
# POST  /group_snapshots
# edited
"group:create_group_snapshot": "rule:admin_or_owner or rule:is_member"

# Show group snapshot.
# GET  /group_snapshots/{group_snapshot_id}
# edited
"group:get_group_snapshot": "rule:admin_or_owner or rule:is_member or rule:is_reader"

# Delete group snapshot.
# DELETE  /group_snapshots/{group_snapshot_id}
# edited
"group:delete_group_snapshot": "rule:admin_or_owner or rule:is_member"

# Update group snapshot.
# PUT  /group_snapshots/{group_snapshot_id}
# edited
"group:update_group_snapshot": "rule:admin_or_owner or rule:is_member"





















# Extend a volume.
# POST  /volumes/{volume_id}/action (os-extend)
# edited
"volume:extend": "rule:admin_or_owner or rule:is_member"

# Extend a attached volume.
# POST  /volumes/{volume_id}/action (os-extend)
# edited
"volume:extend_attached_volume": "rule:admin_or_owner or rule:is_member"

# Revert a volume to a snapshot.
# POST  /volumes/{volume_id}/action (revert)
# edited
"volume:revert_to_snapshot": "rule:admin_or_owner or rule:is_member"









# Upload a volume to image.
# POST  /volumes/{volume_id}/action (os-volume_upload_image)
# edited
"volume_extension:volume_actions:upload_image": "rule:admin_or_owner or rule:is_member"




# Initialize volume attachment.
# POST  /volumes/{volume_id}/action (os-initialize_connection)
# edited
"volume_extension:volume_actions:initialize_connection": "rule:admin_or_owner or rule:is_member"

# Terminate volume attachment.
# POST  /volumes/{volume_id}/action (os-terminate_connection)
# edited
"volume_extension:volume_actions:terminate_connection": "rule:admin_or_owner or rule:is_member"

# Roll back volume status to 'in-use'.
# POST  /volumes/{volume_id}/action (os-roll_detaching)
# edited
"volume_extension:volume_actions:roll_detaching": "rule:admin_or_owner or rule:is_member"

# Mark volume as reserved.
# POST  /volumes/{volume_id}/action (os-reserve)
# edited
"volume_extension:volume_actions:reserve": "rule:admin_or_owner or rule:is_member"

# Unmark volume as reserved.
# POST  /volumes/{volume_id}/action (os-unreserve)
# edited
"volume_extension:volume_actions:unreserve": "rule:admin_or_owner or rule:is_member"

# Begin detach volumes.
# POST  /volumes/{volume_id}/action (os-begin_detaching)
# edited
"volume_extension:volume_actions:begin_detaching": "rule:admin_or_owner or rule:is_member"

# Add attachment metadata.
# POST  /volumes/{volume_id}/action (os-attach)
# edited
"volume_extension:volume_actions:attach": "rule:admin_or_owner or rule:is_member"

# Clear attachment metadata.
# POST  /volumes/{volume_id}/action (os-detach)
# edited
"volume_extension:volume_actions:detach": "rule:admin_or_owner or rule:is_member"

# List volume transfer.
# GET  /os-volume-transfer
# GET  /os-volume-transfer/detail
# edited
"volume:get_all_transfers": "rule:admin_or_owner or rule:is_member or rule:is_reader"

# Create a volume transfer.
# POST  /os-volume-transfer
# edited
"volume:create_transfer": "rule:admin_or_owner or rule:is_member"

# Show one specified volume transfer.
# GET  /os-volume-transfer/{transfer_id}
# edited
"volume:get_transfer": "rule:admin_or_owner or rule:is_member or rule:is_reader"

# Accept a volume transfer.
# POST  /os-volume-transfer/{transfer_id}/accept
# edited
"volume:accept_transfer": "rule:admin_or_owner or rule:is_member"

# Delete volume transfer.
# DELETE  /os-volume-transfer/{transfer_id}
# edited
"volume:delete_transfer": "rule:admin_or_owner or rule:is_member"


# Create volume metadata.
# POST  /volumes/{volume_id}/metadata
# edited
"volume:create_volume_metadata": "rule:admin_or_owner or rule:is_member"

# Update volume's metadata or one specified metadata with a given key.
# PUT  /volumes/{volume_id}/metadata
# PUT  /volumes/{volume_id}/metadata/{key}
# edited
"volume:update_volume_metadata": "rule:admin_or_owner or rule:is_member"

# Delete volume's specified metadata with a given key.
# DELETE  /volumes/{volume_id}/metadata/{key}
# edited
"volume:delete_volume_metadata": "rule:admin_or_owner or rule:is_member"

# Volume's image metadata related operation, create, delete, show and
# list.
# GET  /volumes/detail
# GET  /volumes/{volume_id}
# POST  /volumes/{volume_id}/action (os-set_image_metadata)
# POST  /volumes/{volume_id}/action (os-unset_image_metadata)
# edited
"volume_extension:volume_image_metadata": "rule:admin_or_owner or rule:is_member"


# Create volume.
# POST  /volumes
# edited
"volume:create": "rule:admin_or_owner or rule:is_member"

# Create volume from image.
# POST  /volumes
# edited
"volume:create_from_image": "rule:admin_or_owner or rule:is_member"

# Show volume.
# GET  /volumes/{volume_id}
# edited
"volume:get": "rule:admin_or_owner or rule:is_member or rule:is_reader"

# List volumes.
# GET  /volumes
# GET  /volumes/detail
# edited
"volume:get_all": "rule:admin_or_owner or rule:is_member or rule:is_reader"

# Update volume.
# PUT  /volumes
# edited
"volume:update": "rule:admin_or_owner or rule:is_member"

# Delete volume.
# DELETE  /volumes/{volume_id}
# edited
"volume:delete": "rule:admin_or_owner or rule:is_member"




# List or show volume with tenant attribute.
# GET  /volumes/{volume_id}
# GET  /volumes/detail
# edited
"volume_extension:volume_tenant_attribute": "rule:admin_or_owner or rule:is_member or rule:is_reader"


# Show volume's encryption metadata.
# GET  /volumes/{volume_id}/encryption
# GET  /volumes/{volume_id}/encryption/{encryption_key}
# edited
"volume_extension:volume_encryption_metadata": "rule:admin_or_owner or rule:is_member"

# Create multiattach capable volume.
# POST  /volumes
# edited
"volume:multiattach": "rule:admin_or_owner or rule:is_member"

EOF


