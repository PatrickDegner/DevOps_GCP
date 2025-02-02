resource "google_artifact_registry_repository" "devops-repo" {
  location      = var.region
  repository_id = "devops-repo"
  description   = "DevOps repository"
  format        = "DOCKER"
}

resource "google_container_cluster" "devops_cluster" {
  name                     = "devops-cluster"
  location                 = var.region
  network                  = google_compute_network.devops_vpc.id
  subnetwork               = google_compute_subnetwork.devops_subnet.name
  remove_default_node_pool = true

  node_pool {
    name       = "pool1"
    node_count = 1

    node_config {
      machine_type = "e2-micro"
    }
  }
}

resource "kubernetes_namespace" "devopsproject" {
  metadata {
    name = "devopsproject"
  }

  depends_on = [google_container_cluster.devops_cluster]
}