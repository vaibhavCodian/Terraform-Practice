# Create VPC network
resource "google_compute_network" "my_vpc" {
  name                  = "pe-training-vpc"
  auto_create_subnetworks = false
}

# Create Private-Subnets
resource "google_compute_subnetwork" "private_subnet_1" {
  name          = "private-subnet-1"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.my_vpc.name
  region        = "us-central1"
}

resource "google_compute_subnetwork" "private_subnet_2" {
  name          = "private-subnet-2"
  ip_cidr_range = "10.0.2.0/24"
  network       = google_compute_network.my_vpc.name
  region        = "us-central1"
}



# Create GCE instance

resource "google_compute_instance" "vm1" {
  name         = "vm1"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  tags = ["vm1"]

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = google_compute_network.my_vpc.name
    subnetwork = google_compute_subnetwork.private_subnet_1.name
    
  }
}

resource "google_compute_instance" "vm2" {
  name         = "vm2"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  tags = ["vm2"]

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = google_compute_network.my_vpc.name
    subnetwork = google_compute_subnetwork.private_subnet_2.name
    # access_config {
    #   nat_ip = null
    # }
  }
}

resource "google_compute_firewall" "allow_internal_traffic" {
  name    = "allow-internal-traffic"
  network = google_compute_network.my_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "icmp"
  }

  # Allowing SSH access
  source_ranges    = ["0.0.0.0/0"]
}


resource "google_compute_firewall" "deny_inbound_to_vm1" {
  name    = "deny-inbound-to-vm1"
  network = google_compute_network.my_vpc.name

  priority = 0

  deny {
    protocol = "icmp"
  }

  source_tags   = ["vm2"]
  target_tags   = ["vm1"]
}

