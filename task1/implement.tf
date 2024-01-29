
resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_subnetwork" "subnet_us_central1" {
  name          = "terraform-subnetwork"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.self_link
}

resource "google_compute_firewall" "iap_firewall_rule" {
  name    = "iap-firewall-rule"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "internal_communication" {
  name    = "internal-communication"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.0.0.0/16"]
}

resource "google_compute_firewall" "health_check_firewall_rule" {
  name    = "health-check-firewall-rule"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
}

resource "google_compute_instance" "default" {
  name         = "terraform-instance"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.subnet_us_central1.name

    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = "sudo apt-get update; sudo apt-get install -y nginx"

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  tags = ["http-server"]
}

# resource "google_compute_instance_group_manager" "mig" {
#   name               = "terraform-mig"
#   base_instance_name = "mig-instance"
#   zone               = "us-central1-a"
#   target_size        = 1

#   version {
#     instance_template = google_compute_instance_template.mig-template.self_link
#   }

#   named_port {
#     name = "http"
#     port = "80"
#   }
# }


