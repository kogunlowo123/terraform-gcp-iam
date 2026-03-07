###############################################################################
# Complete Example — All IAM Features
###############################################################################

module "iam" {
  source = "../../"

  project_id = "my-gcp-project"

  # ---------- Service Accounts ----------
  service_accounts = {
    "cicd-runner" = {
      display_name = "CI/CD Runner"
      description  = "Service account for CI/CD pipeline execution"
    }
    "app-backend" = {
      display_name = "Backend Application"
      description  = "Service account for backend microservices"
    }
    "data-pipeline" = {
      display_name = "Data Pipeline"
      description  = "Service account for batch data processing"
    }
  }

  # ---------- Service Account Keys ----------
  service_account_keys = {
    "data-pipeline-key" = {
      service_account_id = "projects/my-gcp-project/serviceAccounts/data-pipeline@my-gcp-project.iam.gserviceaccount.com"
      key_algorithm      = "KEY_ALG_RSA_2048"
    }
  }

  # ---------- Custom Roles (Project) ----------
  custom_roles = {
    "customStorageAdmin" = {
      title       = "Custom Storage Admin"
      description = "Scoped storage admin for application workloads"
      permissions = [
        "storage.buckets.get",
        "storage.buckets.list",
        "storage.objects.create",
        "storage.objects.delete",
        "storage.objects.get",
        "storage.objects.list",
        "storage.objects.update",
      ]
    }
    "customLoggingWriter" = {
      title       = "Custom Logging Writer"
      description = "Write-only access to Cloud Logging"
      permissions = [
        "logging.logEntries.create",
        "logging.logEntries.route",
      ]
    }
  }

  # ---------- Organization Custom Roles ----------
  org_custom_roles = {
    "orgNetworkViewer" = {
      org_id      = "123456789012"
      title       = "Org Network Viewer"
      description = "Read-only network access at org level"
      permissions = [
        "compute.networks.get",
        "compute.networks.list",
        "compute.subnetworks.get",
        "compute.subnetworks.list",
      ]
    }
  }

  # ---------- Project IAM Bindings ----------
  project_iam_bindings = {
    "backend-editor" = {
      role    = "roles/editor"
      members = ["serviceAccount:app-backend@my-gcp-project.iam.gserviceaccount.com"]
    }
    "data-bq-admin" = {
      role    = "roles/bigquery.admin"
      members = ["serviceAccount:data-pipeline@my-gcp-project.iam.gserviceaccount.com"]
      condition = {
        title       = "weekday-only"
        description = "Grant access only on weekdays"
        expression  = "request.time.getDayOfWeek('America/New_York') >= 1 && request.time.getDayOfWeek('America/New_York') <= 5"
      }
    }
  }

  # ---------- Folder IAM Bindings ----------
  folder_iam_bindings = {
    "folder-viewer" = {
      folder  = "folders/111222333444"
      role    = "roles/viewer"
      members = ["serviceAccount:cicd-runner@my-gcp-project.iam.gserviceaccount.com"]
    }
  }

  # ---------- Organization IAM Bindings ----------
  org_iam_bindings = {
    "org-billing-viewer" = {
      org_id  = "123456789012"
      role    = "roles/billing.viewer"
      members = ["group:finance@example.com"]
    }
  }

  # ---------- Workload Identity Federation ----------
  workload_identity_pools = {
    "github-pool" = {
      display_name = "GitHub Actions Pool"
      description  = "Federation pool for GitHub Actions"
      providers = {
        "github-oidc" = {
          display_name = "GitHub OIDC Provider"
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
    "aws-pool" = {
      display_name = "AWS Federation Pool"
      description  = "Federation pool for AWS cross-cloud access"
      providers = {
        "aws-provider" = {
          display_name = "AWS Provider"
          attribute_mapping = {
            "google.subject"  = "assertion.arn"
            "attribute.aws_role" = "assertion.amr[0]"
          }
          aws = {
            account_id = "123456789012"
          }
        }
      }
    }
  }

  # ---------- Service Account Impersonation ----------
  service_account_impersonation = {
    "admin-impersonate-cicd" = {
      service_account_email = "cicd-runner@my-gcp-project.iam.gserviceaccount.com"
      members = [
        "user:admin@example.com",
        "group:platform-team@example.com",
      ]
    }
    "pipeline-impersonate" = {
      service_account_email = "data-pipeline@my-gcp-project.iam.gserviceaccount.com"
      members               = ["user:data-eng@example.com"]
      condition = {
        title       = "business-hours"
        description = "Only during business hours"
        expression  = "request.time.getHours('America/New_York') >= 9 && request.time.getHours('America/New_York') <= 17"
      }
    }
  }

  # ---------- Organization Policies ----------
  org_policies = {
    "disable-serial-port" = {
      constraint = "compute.disableSerialPortAccess"
      boolean_policy = {
        enforced = true
      }
    }
    "restrict-vm-external-ip" = {
      constraint = "compute.vmExternalIpAccess"
      list_policy = {
        deny = {
          all = true
        }
      }
    }
  }
}

# ---------- Outputs ----------
output "service_account_emails" {
  value = module.iam.service_account_emails
}

output "custom_role_ids" {
  value = module.iam.custom_role_ids
}

output "workload_identity_pool_ids" {
  value = module.iam.workload_identity_pool_ids
}

output "project_number" {
  value = module.iam.project_number
}
