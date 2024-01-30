resource "google_compute_network" "auto-vpc-tf2" {
  name = "auto-vpc-tf2"
  auto_create_subnetworks = true

}

resource "google_compute_network" "custom-vpc-tf2" {
  name = "custom-vpc-tf2"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "sub-sg" {
  name = "sub-sg"
  network = google_compute_network.custom-vpc-tf2.id
  region = "asia-southeast1"
  private_ip_google_access = true
  ip_cidr_range = "10.1.0.0/24"
}

resource "google_compute_firewall" "allow-icmp" {
  name = "allow-icmp"
  network = google_compute_network.custom-vpc-tf2.id

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
  priority = 455
}

output "auto" {
  value = google_compute_network.auto-vpc-tf2.id
}
output "custom" {
  value = google_compute_network.custom-vpc-tf2.id
}
