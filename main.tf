resource "proxmox_virtual_environment_user" "this" {
  for_each = var.users

  user_id         = each.value.user_id
  password        = each.value.password
  enabled         = each.value.enabled
  email           = each.value.email
  first_name      = each.value.first_name
  last_name       = each.value.last_name
  groups          = each.value.groups
  keys            = each.value.keys
  expiration_date = each.value.expiration_date
  comment         = each.value.comment

  dynamic "acl" {
    for_each = each.value.acl
    content {
      path      = acl.value.path
      role_id   = acl.value.role_id
      propagate = acl.value.propagate
    }
  }
}