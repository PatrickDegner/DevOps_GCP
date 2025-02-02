resource "google_compute_network" "devops_vpc" {
  name                    = "devops"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "devops_subnet" {
  name          = "devops-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.devops_vpc.id

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "192.168.64.0/22"
  }

  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "192.168.1.0/24"
  }
}