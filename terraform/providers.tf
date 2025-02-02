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