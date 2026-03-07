###############################################################################
# Advanced Example — Custom Roles, Workload Identity Federation, Impersonation
###############################################################################

module "iam" {
  source = "../../"

  project_id = "my-gcp-project"

  # Service Accounts
  service_accounts = {
    "cicd-runner" = {
      display_name = "CI/CD Runner"
      description  = "Service account used by CI/CD pipelines"
    }
    "app-backend" = {
      display_name = "Backend Application"
      description  = "Service account for backend services"
    }
  }

  # Custom Roles
  custom_roles = {
    "customStorageReader" = {
      title       = "Custom Storage Reader"
      description = "Read-only access to specific GCS operations"
      permissions = [
        "storage.buckets.get",
        "storage.objects.get",
        "storage.objects.list",
      ]
      stage = "GA"
    }
  }

  # Project-Level IAM Bindings with Conditions
  project_iam_bindings = {
    "backend-storage" = {
      role    = "projects/my-gcp-project/roles/customStorageReader"
      members = ["serviceAccount:app-backend@my-gcp-project.iam.gserviceaccount.com"]
      condition = {
        title      = "expires-2025"
        expression = "request.time < timestamp('2025-12-31T00:00:00Z')"
      }
    }
  }

  # Workload Identity Federation for GitHub Actions
  workload_identity_pools = {
    "github-pool" = {
      display_name = "GitHub Actions Pool"
      description  = "Pool for GitHub Actions OIDC federation"
      providers = {
        "github-provider" = {
          display_name = "GitHub OIDC"
          attribute_mapping = {
            "google.subject"       = "assertion.sub"
            "attribute.actor"      = "assertion.actor"
            "attribute.repository" = "assertion.repository"
          }
          attribute_condition = "assertion.repository_owner == 'my-org'"
          oidc = {
            issuer_uri = "https://token.actions.githubusercontent.com"
          }
        }
      }
    }
  }

  # Service Account Impersonation
  service_account_impersonation = {
    "cicd-impersonate" = {
      service_account_email = "cicd-runner@my-gcp-project.iam.gserviceaccount.com"
      members = [
        "user:admin@example.com",
      ]
    }
  }
}

output "workload_identity_pool_ids" {
  value = module.iam.workload_identity_pool_ids
}

output "custom_role_ids" {
  value = module.iam.custom_role_ids
}
