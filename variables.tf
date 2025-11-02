variable "users" {
  type = map(object({
    user_id         = string
    password        = optional(string)
    enabled         = optional(bool, true)
    email           = optional(string)
    first_name      = optional(string)
    last_name       = optional(string)
    groups          = optional(list(string))
    keys            = optional(string)
    expiration_date = optional(string)
    comment         = optional(string, "Managed by Terraform")
    acl = optional(list(object({
      path      = string
      role_id   = string
      propagate = optional(bool, true)
    })), [])
  }))
  description = "Map of Proxmox users to create. The map key is used as a unique identifier for each user."
  default     = {}
}