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

data "google_client_config" "devops_cluster" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.devops_cluster.endpoint}"
  token                  = data.google_client_config.devops_cluster.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.devops_cluster.master_auth[0].cluster_ca_certificate)

  ignore_annotations = [
    "^autopilot\\.gke\\.io\\/.*",
    "^cloud\\.google\\.com\\/.*"
  ]
}