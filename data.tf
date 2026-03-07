data "google_project" "this" {
  project_id = var.project_id
}

data "google_client_config" "this" {}
