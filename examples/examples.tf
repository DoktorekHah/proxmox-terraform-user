# Example usage of the Proxmox Terraform User module

# Example 1: Single user with basic configuration
module "proxmox_users" {
  source = "./path/to/module"

  users = {
    "admin_user" = {
      user_id  = "admin@pve"
      password = "secure_password_here"
      enabled  = true
      comment  = "Administrator account"
      acl = [{
        path      = "/"
        role_id   = "Administrator"
        propagate = true
      }]
    }
  }
}

# Example 2: Multiple users with different configurations
module "proxmox_multiple_users" {
  source = "./path/to/module"

  users = {
    "developer1" = {
      user_id    = "dev1@pve"
      password   = "dev1_password"
      enabled    = true
      email      = "dev1@example.com"
      first_name = "John"
      last_name  = "Doe"
      groups     = ["developers", "testers"]
      comment    = "Developer account"
      acl = [{
        path      = "/vms"
        role_id   = "PVEVMAdmin"
        propagate = true
      }]
    }

    "developer2" = {
      user_id         = "dev2@pve"
      password        = "dev2_password"
      enabled         = true
      email           = "dev2@example.com"
      first_name      = "Jane"
      last_name       = "Smith"
      groups          = ["developers"]
      expiration_date = "2026-12-31"
      comment         = "Temporary developer account"
      acl = [
        {
          path      = "/vms"
          role_id   = "PVEVMUser"
          propagate = true
        },
        {
          path      = "/storage"
          role_id   = "PVEDatastoreUser"
          propagate = false
        }
      ]
    }

    "readonly_user" = {
      user_id = "readonly@pve"
      password = "readonly_password"
      enabled = true
      comment = "Read-only monitoring account"
      acl = [{
        path      = "/"
        role_id   = "PVEAuditor"
        propagate = true
      }]
    }
  }
}

# Example 3: User with SSH keys
module "proxmox_user_with_keys" {
  source = "./path/to/module"

  users = {
    "ssh_user" = {
      user_id = "sshuser@pve"
      enabled = true
      keys    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... user@host"
      comment = "SSH access account"
      acl = [{
        path      = "/nodes/node1"
        role_id   = "Administrator"
        propagate = false
      }]
    }
  }
}

# Access outputs
output "all_users" {
  value = module.proxmox_users.users
}

output "user_ids_only" {
  value = module.proxmox_users.user_ids
}

output "user_acls_only" {
  value = module.proxmox_users.user_acls
}

