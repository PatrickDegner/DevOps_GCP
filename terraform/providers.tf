terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.5"
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
  token                  = google_container_cluster.devops_cluster.master_auth[0].token
  cluster_ca_certificate = base64decode(google_container_cluster.devops_cluster.master_auth[0].cluster_ca_certificate)
}