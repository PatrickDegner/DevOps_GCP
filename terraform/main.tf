locals {
  services = toset([
    "iam.googleapis.com",                  # Identity and Access Management (IAM) API
    "iamcredentials.googleapis.com",       # IAM Service Account Credentials API
    "cloudresourcemanager.googleapis.com", # Cloud Resource Manager API
    "sts.googleapis.com",                  # Security Token Service API
  ])
}

resource "google_project_service" "service" {
  for_each = local.services
  project  = var.project
  service  = each.value
}
