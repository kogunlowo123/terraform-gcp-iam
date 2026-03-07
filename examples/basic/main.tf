###############################################################################
# Basic Example — Service Account with Project IAM Binding
###############################################################################

module "iam" {
  source = "../../"

  project_id = "my-gcp-project"

  service_accounts = {
    "app-service-acct" = {
      display_name = "Application Service Account"
      description  = "Service account for the application workload"
    }
  }

  project_iam_bindings = {
    "app-viewer" = {
      role    = "roles/viewer"
      members = ["serviceAccount:app-service-acct@my-gcp-project.iam.gserviceaccount.com"]
    }
  }
}

output "service_account_emails" {
  value = module.iam.service_account_emails
}
