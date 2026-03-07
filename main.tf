###############################################################################
# Service Accounts
###############################################################################

resource "google_service_account" "this" {
  for_each = local.service_accounts

  account_id   = each.key
  display_name = each.value.display_name
  description  = each.value.description
  disabled     = each.value.disabled
  project      = each.value.project
}

###############################################################################
# Service Account Keys
###############################################################################

resource "google_service_account_key" "this" {
  for_each = var.service_account_keys

  service_account_id = each.value.service_account_id
  key_algorithm      = each.value.key_algorithm
  public_key_type    = each.value.public_key_type
  private_key_type   = each.value.private_key_type
}

###############################################################################
# Custom Roles (Project Level)
###############################################################################

resource "google_project_iam_custom_role" "this" {
  for_each = var.custom_roles

  role_id     = each.key
  title       = each.value.title
  description = each.value.description
  permissions = each.value.permissions
  stage       = each.value.stage
  project     = var.project_id
}

###############################################################################
# Custom Roles (Organization Level)
###############################################################################

resource "google_organization_iam_custom_role" "this" {
  for_each = var.org_custom_roles

  role_id     = each.key
  org_id      = each.value.org_id
  title       = each.value.title
  description = each.value.description
  permissions = each.value.permissions
  stage       = each.value.stage
}

###############################################################################
# Project-Level IAM Bindings
###############################################################################

resource "google_project_iam_member" "this" {
  for_each = merge([
    for binding_key, binding in local.project_iam_bindings : {
      for member in binding.members :
      "${binding_key}/${member}" => {
        project = binding.project
        role    = binding.role
        member  = member
        condition = binding.condition
      }
    }
  ]...)

  project = each.value.project
  role    = each.value.role
  member  = each.value.member

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

###############################################################################
# Folder-Level IAM Bindings
###############################################################################

resource "google_folder_iam_member" "this" {
  for_each = merge([
    for binding_key, binding in var.folder_iam_bindings : {
      for member in binding.members :
      "${binding_key}/${member}" => {
        folder = binding.folder
        role   = binding.role
        member = member
        condition = binding.condition
      }
    }
  ]...)

  folder = each.value.folder
  role   = each.value.role
  member = each.value.member

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

###############################################################################
# Organization-Level IAM Bindings
###############################################################################

resource "google_organization_iam_member" "this" {
  for_each = merge([
    for binding_key, binding in var.org_iam_bindings : {
      for member in binding.members :
      "${binding_key}/${member}" => {
        org_id = binding.org_id
        role   = binding.role
        member = member
        condition = binding.condition
      }
    }
  ]...)

  org_id = each.value.org_id
  role   = each.value.role
  member = each.value.member

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

###############################################################################
# Workload Identity Pools
###############################################################################

resource "google_iam_workload_identity_pool" "this" {
  for_each = var.workload_identity_pools

  workload_identity_pool_id = each.key
  display_name              = each.value.display_name
  description               = each.value.description
  disabled                  = each.value.disabled
  project                   = var.project_id
}

###############################################################################
# Workload Identity Pool Providers
###############################################################################

resource "google_iam_workload_identity_pool_provider" "this" {
  for_each = local.wip_providers

  workload_identity_pool_id          = google_iam_workload_identity_pool.this[each.value.pool_id].workload_identity_pool_id
  workload_identity_pool_provider_id = each.value.provider_id
  display_name                       = each.value.display_name
  description                        = each.value.description
  disabled                           = each.value.disabled
  attribute_mapping                  = each.value.attribute_mapping
  attribute_condition                = each.value.attribute_condition
  project                            = var.project_id

  dynamic "oidc" {
    for_each = each.value.oidc != null ? [each.value.oidc] : []
    content {
      issuer_uri        = oidc.value.issuer_uri
      allowed_audiences = oidc.value.allowed_audiences
      jwks_json         = oidc.value.jwks_json
    }
  }

  dynamic "aws" {
    for_each = each.value.aws != null ? [each.value.aws] : []
    content {
      account_id = aws.value.account_id
    }
  }
}

###############################################################################
# Service Account Impersonation
###############################################################################

resource "google_service_account_iam_member" "impersonation" {
  for_each = merge([
    for key, binding in var.service_account_impersonation : {
      for member in binding.members :
      "${key}/${member}" => {
        service_account_id = binding.service_account_email
        member             = member
        condition          = binding.condition
      }
    }
  ]...)

  service_account_id = each.value.service_account_id
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = each.value.member

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

###############################################################################
# Organization Policies
###############################################################################

resource "google_project_organization_policy" "this" {
  for_each = var.org_policies

  project    = var.project_id
  constraint = each.value.constraint

  dynamic "boolean_policy" {
    for_each = each.value.boolean_policy != null ? [each.value.boolean_policy] : []
    content {
      enforced = boolean_policy.value.enforced
    }
  }

  dynamic "list_policy" {
    for_each = each.value.list_policy != null ? [each.value.list_policy] : []
    content {
      dynamic "allow" {
        for_each = list_policy.value.allow != null ? [list_policy.value.allow] : []
        content {
          values = allow.value.values
          all    = allow.value.all
        }
      }
      dynamic "deny" {
        for_each = list_policy.value.deny != null ? [list_policy.value.deny] : []
        content {
          values = deny.value.values
          all    = deny.value.all
        }
      }
      suggested_value = list_policy.value.suggested_value
    }
  }
}
