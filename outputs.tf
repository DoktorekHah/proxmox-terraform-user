output "users" {
  value = {
    for key, user in proxmox_virtual_environment_user.this : key => {
      id      = user.id
      user_id = user.user_id
      enabled = user.enabled
      comment = user.comment
      email   = user.email
      groups  = user.groups
      acl     = user.acl
    }
  }
  description = "Map of all created users with their details"
}

output "user_ids" {
  value = {
    for key, user in proxmox_virtual_environment_user.this : key => user.user_id
  }
  description = "Map of user keys to their user_id"
}

output "user_acls" {
  value = {
    for key, user in proxmox_virtual_environment_user.this : key => user.acl
  }
  description = "Map of user keys to their ACL configurations"
}

