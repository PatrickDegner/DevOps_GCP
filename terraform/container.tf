resource "google_artifact_registry_repository" "my-repo" {
  location      = var.region
  repository_id = "devops-repo"
  description   = "DevOps repository"
  format        = "DOCKER"
}
