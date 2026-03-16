variable "project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be 6-30 characters, start with a letter, and contain only lowercase letters, digits, and hyphens."
  }
}

variable "service_accounts" {
  description = "Map of service accounts to create, keyed by account_id."
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

variable "service_account_keys" {
  description = "Map of service account keys to create, keyed by logical name."
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

variable "custom_roles" {
  description = "Map of custom IAM roles to create at the project level, keyed by role_id."
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
  description = "Map of custom IAM roles to create at the organization level, keyed by role_id."
  type = map(object({
    org_id      = string
    title       = string
    description = optional(string, "")
    permissions = list(string)
    stage       = optional(string, "GA")
  }))
  default = {}
}

variable "project_iam_bindings" {
  description = "Map of project-level IAM bindings, keyed by logical name."
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

variable "folder_iam_bindings" {
  description = "Map of folder-level IAM bindings, keyed by logical name."
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

variable "org_iam_bindings" {
  description = "Map of organization-level IAM bindings, keyed by logical name."
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

variable "workload_identity_pools" {
  description = "Map of Workload Identity Pools to create, keyed by pool_id."
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

variable "service_account_impersonation" {
  description = "Map of service account impersonation bindings granting serviceAccountTokenCreator."
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

variable "org_policies" {
  description = "Map of organization policy constraints to apply at project level."
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
