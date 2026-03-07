###############################################################################
# Service Accounts
###############################################################################

output "service_account_emails" {
  description = "Map of service account IDs to their email addresses."
  value       = { for k, v in google_service_account.this : k => v.email }
}

output "service_account_ids" {
  description = "Map of service account IDs to their fully-qualified resource IDs."
  value       = { for k, v in google_service_account.this : k => v.id }
}

output "service_account_unique_ids" {
  description = "Map of service account IDs to their unique numeric IDs."
  value       = { for k, v in google_service_account.this : k => v.unique_id }
}

output "service_account_names" {
  description = "Map of service account IDs to their fully-qualified names."
  value       = { for k, v in google_service_account.this : k => v.name }
}

###############################################################################
# Service Account Keys
###############################################################################

output "service_account_key_ids" {
  description = "Map of service account key logical names to their IDs."
  value       = { for k, v in google_service_account_key.this : k => v.id }
}

output "service_account_key_public_keys" {
  description = "Map of service account key logical names to their public keys."
  value       = { for k, v in google_service_account_key.this : k => v.public_key }
}

###############################################################################
# Custom Roles
###############################################################################

output "custom_role_ids" {
  description = "Map of custom role IDs to their fully-qualified resource IDs."
  value       = { for k, v in google_project_iam_custom_role.this : k => v.id }
}

output "org_custom_role_ids" {
  description = "Map of organization custom role IDs to their fully-qualified resource IDs."
  value       = { for k, v in google_organization_iam_custom_role.this : k => v.id }
}

###############################################################################
# Workload Identity
###############################################################################

output "workload_identity_pool_ids" {
  description = "Map of workload identity pool IDs to their fully-qualified resource IDs."
  value       = { for k, v in google_iam_workload_identity_pool.this : k => v.id }
}

output "workload_identity_pool_names" {
  description = "Map of workload identity pool IDs to their resource names."
  value       = { for k, v in google_iam_workload_identity_pool.this : k => v.name }
}

output "workload_identity_pool_provider_ids" {
  description = "Map of workload identity pool provider composite keys to their fully-qualified resource IDs."
  value       = { for k, v in google_iam_workload_identity_pool_provider.this : k => v.id }
}

###############################################################################
# Project
###############################################################################

output "project_id" {
  description = "The GCP project ID."
  value       = var.project_id
}

output "project_number" {
  description = "The GCP project number."
  value       = data.google_project.this.number
}
