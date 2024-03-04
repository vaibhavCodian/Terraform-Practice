# Create VPC network
resource "google_compute_network" "vpc" {
  name                    = "vpc"
  auto_create_subnetworks = "false"
}


# Create Private-Subnets

resource "google_compute_subnetwork" "subnet" {
  name          = "subnet"
  ip_cidr_range = "10.0.0.0/16"
  network       = google_compute_network.vpc.self_link
}


#  Create GCE instance

resource "google_compute_instance" "default" {
  name         = "smtp-server"
  machine_type = "f1-micro"
  zone         = "us-central1-c"

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {

    network    = google_compute_network.vpc.self_link
    subnetwork = google_compute_subnetwork.subnet.self_link

    access_config {
      // Ephemeral IP
    }

  }

    metadata = {
      hostname = "smtp-server.qr-poc.com"
    }
}



# networking configuraton
resource "google_compute_firewall" "allow_ssh_traffic" {
  name    = "allow-ssh-traffic"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "email-server" {
  name    = "email-server-firewall"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["25", "110", "143", "587"]
  }

  source_ranges = ["0.0.0.0/0"]
}


