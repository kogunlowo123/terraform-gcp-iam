###############################################################################
# General
###############################################################################

variable "project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be 6-30 characters, start with a letter, and contain only lowercase letters, digits, and hyphens."
  }
}

###############################################################################
# Service Accounts
###############################################################################

variable "service_accounts" {
  description = <<-EOT
    Map of service accounts to create.
    Key is the account_id (unique identifier).
    EOT
  type = map(object({
    display_name = optional(string, "")
    description  = optional(string, "")
    disabled     = optional(bool, false)
    project      = optional(string, null)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.service_accounts :
      can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", k))
    ])
    error_message = "Service account IDs must be 6-30 characters, start with a letter, and contain only lowercase letters, digits, and hyphens."
  }
}

###############################################################################
# Service Account Keys
###############################################################################

variable "service_account_keys" {
  description = <<-EOT
    Map of service account keys to create.
    Key is a logical name; service_account_id must reference a service account.
    EOT
  type = map(object({
    service_account_id = string
    key_algorithm      = optional(string, "KEY_ALG_RSA_2048")
    public_key_type    = optional(string, "TYPE_X509_PEM_FILE")
    private_key_type   = optional(string, "TYPE_GOOGLE_CREDENTIALS_FILE")
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.service_account_keys :
      contains(["KEY_ALG_RSA_1024", "KEY_ALG_RSA_2048"], v.key_algorithm)
    ])
    error_message = "key_algorithm must be KEY_ALG_RSA_1024 or KEY_ALG_RSA_2048."
  }
}

###############################################################################
# Custom Roles
###############################################################################

variable "custom_roles" {
  description = <<-EOT
    Map of custom IAM roles to create at the project level.
    Key is the role_id.
    EOT
  type = map(object({
    title       = string
    description = optional(string, "")
    permissions = list(string)
    stage       = optional(string, "GA")
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.custom_roles :
      contains(["ALPHA", "BETA", "GA", "DEPRECATED", "DISABLED", "EAP"], v.stage)
    ])
    error_message = "Custom role stage must be one of: ALPHA, BETA, GA, DEPRECATED, DISABLED, EAP."
  }
}

variable "org_custom_roles" {
  description = <<-EOT
    Map of custom IAM roles to create at the organization level.
    Key is the role_id.
    EOT
  type = map(object({
    org_id      = string
    title       = string
    description = optional(string, "")
    permissions = list(string)
    stage       = optional(string, "GA")
  }))
  default = {}
}

###############################################################################
# Project-Level IAM Bindings
###############################################################################

variable "project_iam_bindings" {
  description = <<-EOT
    Map of project-level IAM bindings.
    Key is a logical name; role and members are required.
    EOT
  type = map(object({
    project = optional(string, null)
    role    = string
    members = list(string)
    condition = optional(object({
      title       = string
      description = optional(string, "")
      expression  = string
    }), null)
  }))
  default = {}
}

###############################################################################
# Folder-Level IAM Bindings
###############################################################################

variable "folder_iam_bindings" {
  description = <<-EOT
    Map of folder-level IAM bindings.
    Key is a logical name.
    EOT
  type = map(object({
    folder  = string
    role    = string
    members = list(string)
    condition = optional(object({
      title       = string
      description = optional(string, "")
      expression  = string
    }), null)
  }))
  default = {}
}

###############################################################################
# Organization-Level IAM Bindings
###############################################################################

variable "org_iam_bindings" {
  description = <<-EOT
    Map of organization-level IAM bindings.
    Key is a logical name.
    EOT
  type = map(object({
    org_id  = string
    role    = string
    members = list(string)
    condition = optional(object({
      title       = string
      description = optional(string, "")
      expression  = string
    }), null)
  }))
  default = {}
}

###############################################################################
# Workload Identity Federation
###############################################################################

variable "workload_identity_pools" {
  description = <<-EOT
    Map of Workload Identity Pools to create.
    Key is the pool_id.
    EOT
  type = map(object({
    display_name = optional(string, "")
    description  = optional(string, "")
    disabled     = optional(bool, false)
    providers = optional(map(object({
      display_name        = optional(string, "")
      description         = optional(string, "")
      disabled            = optional(bool, false)
      attribute_mapping   = map(string)
      attribute_condition = optional(string, null)
      oidc = optional(object({
        issuer_uri        = string
        allowed_audiences = optional(list(string), [])
        jwks_json         = optional(string, null)
      }), null)
      aws = optional(object({
        account_id = string
      }), null)
    })), {})
  }))
  default = {}
}

###############################################################################
# Service Account Impersonation
###############################################################################

variable "service_account_impersonation" {
  description = <<-EOT
    Map of service account impersonation bindings.
    Grants 'roles/iam.serviceAccountTokenCreator' to specified members.
    EOT
  type = map(object({
    service_account_email = string
    members               = list(string)
    condition = optional(object({
      title       = string
      description = optional(string, "")
      expression  = string
    }), null)
  }))
  default = {}
}

###############################################################################
# Organization Policies
###############################################################################

variable "org_policies" {
  description = <<-EOT
    Map of organization policy constraints to apply at project level.
    Key is the constraint name (e.g., 'compute.disableSerialPortAccess').
    EOT
  type = map(object({
    constraint = string
    boolean_policy = optional(object({
      enforced = bool
    }), null)
    list_policy = optional(object({
      allow = optional(object({
        values = optional(list(string), [])
        all    = optional(bool, false)
      }), null)
      deny = optional(object({
        values = optional(list(string), [])
        all    = optional(bool, false)
      }), null)
      suggested_value = optional(string, null)
    }), null)
  }))
  default = {}
}
