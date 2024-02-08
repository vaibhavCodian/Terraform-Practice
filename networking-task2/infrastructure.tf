# 1. Create 2 VPC networks (VPC A & VPC B) and 2 subnets in it.

resource "google_compute_network" "vpc_a" {
  name                    = "vpc-a"
  auto_create_subnetworks = false
}

resource "google_compute_network" "vpc_b" {
  name                    = "vpc-b"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "subnet_a" {
  name          = "subnet-a"
  ip_cidr_range = "10.0.0.0/16"
  network       = google_compute_network.vpc_a.self_link
}

resource "google_compute_subnetwork" "subnet_b" {
  name          = "subnet-b"
  ip_cidr_range = "10.1.0.0/16"
  network       = google_compute_network.vpc_b.self_link
}

# 2. Create 3 VMs: 1 VM in each network (VM A in VPC A, VM B in VPC B) and 1 VM (VM Router) which will serve as a router. 
# This VM should be connected to both VPC networks, and should have IP forwarding turned on.

# VM A
resource "google_compute_instance" "vm_a" {
  name         = "vm-a"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network       = google_compute_network.vpc_a.self_link
    subnetwork    = google_compute_subnetwork.subnet_a.self_link
    access_config {
      // Ephemeral IP
    }
  }
}

# VM B
resource "google_compute_instance" "vm_b" {
  name         = "vm-b"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network       = google_compute_network.vpc_b.self_link
    subnetwork    = google_compute_subnetwork.subnet_b.self_link
    access_config {
      // Ephemeral IP
    }
  }
}

# VM Router
resource "google_compute_instance" "vm_router" {
  name         = "vm-router"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network       = google_compute_network.vpc_a.self_link
    subnetwork    = google_compute_subnetwork.subnet_a.self_link
    
    access_config {
      // Ephemeral IP
    }
  }

  network_interface {
    network       = google_compute_network.vpc_b.self_link
    subnetwork    = google_compute_subnetwork.subnet_b.self_link
    
    access_config {
      // Ephemeral IP
    }
  }

  can_ip_forward = true
}


# Firewall Rule To Allow Internal Communication

resource "google_compute_firewall" "allow_internal_traffic-vpc-a" {
  name    = "allow-internal-traffic-a"
  network = google_compute_network.vpc_a.name

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

resource "google_compute_firewall" "allow_internal_traffic-vpc-b" {
  name    = "allow-internal-traffic-b"
  network = google_compute_network.vpc_b.name

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

# Route for VPC A
resource "google_compute_route" "route_vpc_a" {
  name        = "route-vpc-a"
  dest_range  = "10.1.0.0/16"
  network     = google_compute_network.vpc_a.self_link
  next_hop_instance = google_compute_instance.vm_router.self_link
  next_hop_instance_zone = "us-central1-a"
}

# Route for VPC B
resource "google_compute_route" "route_vpc_b" {
  name        = "route-vpc-b"
  dest_range  = "10.0.0.0/16"
  network     = google_compute_network.vpc_b.self_link
  next_hop_instance = google_compute_instance.vm_router.self_link
  next_hop_instance_zone = "us-central1-a"
}


# STEP: 3. to 11. performed on WEB INTERFACE


