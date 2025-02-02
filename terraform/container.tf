resource "google_artifact_registry_repository" "devops-repo" {
  location      = var.region
  repository_id = "devops-repo"
  description   = "DevOps repository"
  format        = "DOCKER"
}

resource "google_container_cluster" "devops_cluster" {
  name               = "devops-cluster"
  location           = var.region
  initial_node_count = 1
  network = google_compute_network.devops_vpc.id
  subnetwork = google_compute_subnetwork.devops_subnet.name

  node_pool {
    name         = "default-pool"
    node_count   = 1
    node_config {
      machine_type = "e2-standard-2"
    }
  }
}