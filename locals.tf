locals {
  # Resolve project for service accounts — fall back to var.project_id
  service_accounts = {
    for k, v in var.service_accounts : k => merge(v, {
      project = coalesce(v.project, var.project_id)
    })
  }

  # Resolve project for project IAM bindings
  project_iam_bindings = {
    for k, v in var.project_iam_bindings : k => merge(v, {
      project = coalesce(v.project, var.project_id)
    })
  }

  # Flatten workload identity providers for iteration
  wip_providers = merge([
    for pool_id, pool in var.workload_identity_pools : {
      for provider_id, provider in pool.providers :
      "${pool_id}/${provider_id}" => merge(provider, {
        pool_id     = pool_id
        provider_id = provider_id
      })
    }
  ]...)

  # Build service account email map for easy referencing
  service_account_emails = {
    for k, v in google_service_account.this : k => v.email
  }

  # Build custom role ID map
  custom_role_ids = {
    for k, v in google_project_iam_custom_role.this : k => v.id
  }
}
