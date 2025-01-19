terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.5"
    }
  }

  backend "gcs" {
    bucket = "devops-project-448307-terraform" # need to update with the bucket name
    prefix = "state"
  }
}

provider "google" {
  project = var.project
  region  = var.region
}