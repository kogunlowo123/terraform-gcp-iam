module "test" {
  source = "../"

  project_id = "test-project-id"

  service_accounts = {
    "test-service-acct" = {
      display_name = "Test Service Account"
      description  = "Service account for testing"
      disabled     = false
    }
  }

  custom_roles = {
    "testCustomRole" = {
      title       = "Test Custom Role"
      description = "A custom role for testing purposes"
      permissions = [
        "storage.buckets.get",
        "storage.buckets.list",
        "storage.objects.get",
        "storage.objects.list",
      ]
      stage = "GA"
    }
  }

  project_iam_bindings = {
    "storage-viewer" = {
      role    = "roles/storage.objectViewer"
      members = ["serviceAccount:test-service-acct@test-project-id.iam.gserviceaccount.com"]
    }
  }

  workload_identity_pools = {
    "github-pool" = {
      display_name = "GitHub Actions Pool"
      description  = "Workload Identity Pool for GitHub Actions"
      providers = {
        "github-provider" = {
          display_name = "GitHub Provider"
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
}
