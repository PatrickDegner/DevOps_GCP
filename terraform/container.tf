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
  deletion_protection      = false
  node_locations = [
    "europe-west4-a" # Zonal cluster
  ]

  ip_allocation_policy {
    stack_type                    = "IPV4_IPV6"
    services_secondary_range_name = google_compute_subnetwork.devops_subnet.secondary_ip_range[0].range_name
    cluster_secondary_range_name  = google_compute_subnetwork.devops_subnet.secondary_ip_range[1].range_name
  }
}

resource "google_container_node_pool" "devops_node_pool" {
  name       = "devops-pool"
  cluster    = google_container_cluster.devops_cluster.name
  location   = var.region
  node_count = 1

  node_config {
    machine_type = "e2-micro"
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  depends_on = [google_container_cluster.devops_cluster]
}

resource "kubernetes_namespace" "devopsproject" {
  metadata {
    name = "devopsproject"
  }

  depends_on = [google_container_cluster.devops_cluster]
}