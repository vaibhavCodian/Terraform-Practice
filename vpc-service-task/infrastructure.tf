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

resource "google_compute_instance" "vm" {
  name         = "vm"
  machine_type = "f1-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network    = google_compute_network.vpc.self_link
    subnetwork = google_compute_subnetwork.subnet.self_link
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

# Setup NAT

resource "google_compute_router" "router" {
  name    = "nat-router"
  network = google_compute_network.vpc.self_link
  region  = "us-central1"

}

resource "google_compute_router_nat" "nat" {
  name                               = "nat-config"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}


# INTERNET GATEWAY ROUTES

resource "google_compute_route" "route" {
  name        = "internet-gateway-route"
  dest_range  = "0.0.0.0/0"
  network     = google_compute_network.vpc.self_link
  next_hop_gateway = "default-internet-gateway"
}

resource "null_resource" "delete_route" {
  provisioner "local-exec" {
    command = "gcloud compute routes delete ${google_compute_route.route.name} --quiet"
  }
  depends_on = [google_compute_route.route]
}




# routes outputs
output "routes" {
  value       = google_compute_router.router
  description = "The created routes resources"
}
# nat outputs
output "name" {
  description = "The name of the created Cloud NAT instance"
  value       = google_compute_router_nat.nat
}

