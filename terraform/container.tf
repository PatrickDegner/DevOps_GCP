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
  subnetwork               = google_compute_subnetwork.devops_subnet.id
  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-ranges"
    services_secondary_range_name = google_compute_subnetwork.devops_subnet.secondary_ip_range[0].range_name
  }
}

resource "google_container_node_pool" "devops_node_pool" {
  name       = "devops-pool"
  cluster    = google_container_cluster.devops_cluster.name
  location   = var.region
  node_count = 1

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  depends_on = [google_container_cluster.devops_cluster]
}

resource "kubernetes_namespace" "devopsproject" {
  metadata {
    name = "devopsproject"
  }

  depends_on = [google_container_cluster.devops_cluster]
}

resource "kubernetes_namespace" "devopsproject" {
  metadata {
    name = "devopsproject"
  }

  depends_on = [google_container_cluster.devops_cluster]
}