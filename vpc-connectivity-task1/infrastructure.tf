# Create VPC network
resource "google_compute_network" "vpc1" {
  name                    = "vpc1"
  auto_create_subnetworks = "false"
}

resource "google_compute_network" "vpc2" {
  name                    = "vpc2"
  auto_create_subnetworks = "false"
}


# Create Private-Subnets
resource "google_compute_subnetwork" "subnet1" {
  name          = "subnet1"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc1.self_link
}

resource "google_compute_subnetwork" "subnet2" {
  name          = "subnet2"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc2.self_link
}

# Create GCE instance

resource "google_compute_instance" "vm1" {
  name         = "vm1"
  tags = ["vm1"]
  machine_type = "f1-micro"
  boot_disk {
    initialize_params {
      image = var.image
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet1.self_link
  }
}

resource "google_compute_instance" "vm2" {
  name         = "vm2"
  tags = ["vm2"]
  machine_type = "f1-micro"
  boot_disk {
    initialize_params {
      image = var.image
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet2.self_link
  }
}

# networking configuraton

resource "google_compute_firewall" "allow_ssh_traffic-1" {
  name    = "allow-ssh-traffic-1"
  network = google_compute_network.vpc1.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Allowing SSH access
  source_ranges    = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_ssh_traffic-2" {
  name    = "allow-ssh-traffic-2"
  network = google_compute_network.vpc2.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Allowing SSH access
  source_ranges    = ["0.0.0.0/0"]
}


// Set up VPC peering between vpc1 and vpc2
resource "google_compute_network_peering" "peering1" {
  name         = "peering1"
  network      = google_compute_network.vpc1.self_link
  peer_network = google_compute_network.vpc2.self_link
}

resource "google_compute_network_peering" "peering2" {
  name         = "peering2"
  network      = google_compute_network.vpc2.self_link
  peer_network = google_compute_network.vpc1.self_link
}


# Allow ICMP


// allow traffic from VM1 to VM2
resource "google_compute_firewall" "fw1" {
  name    = "fw1"
  network = google_compute_network.vpc1.self_link

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/24"]
  target_tags   = ["vm2"]
}

// deny traffic from VM2 to VM1
resource "google_compute_firewall" "fw2" {
  name               = "fw2"
  network            = google_compute_network.vpc2.self_link
  direction          = "INGRESS"

  deny {
    protocol = "all"
  }
  
  source_ranges      = ["10.0.1.0/24"]
  target_tags        = ["vm1"]

}


// allow ICMP traffic in VPC2
resource "google_compute_firewall" "allow_icmp_vpc2" {
  name    = "allow-icmp-vpc2"
  network = google_compute_network.vpc2.self_link

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/24"]
}

