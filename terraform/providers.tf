terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.3"

    }
  }

  backend "gcs" {
    bucket = "devops-project-448307-terraform"
    prefix = "state"
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

provider "kubernetes" {
  host                   = google_container_cluster.devops_cluster.endpoint
  cluster_ca_certificate = base64decode(google_container_cluster.devops_cluster.master_auth[0].cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "gcloud"
    args = [
      "container",
      "clusters",
      "get-credentials",
      google_container_cluster.devops_cluster.name,
      "--region",
      google_container_cluster.devops_cluster.location,
      "--project",
      var.project,
    ]
  }
}