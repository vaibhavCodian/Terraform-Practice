
# A. Creating VPC and Subnet in US-central-1
resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_us_central1" {
  name          = var.subnet_name
  ip_cidr_range = var.ip_cidr_range
  region        = var.region
  network       = google_compute_network.vpc_network.self_link
}

# B. Creating Firewall rules to allow IAP and Internal Communications in the subnet
resource "google_compute_firewall" "allow_iap_firewall_rule" {
  name    = var.compute_allow_iap_firewall_name
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = var.allow_iap_ports
  }

  source_ranges = var.source_ranges_iap
}

resource "google_compute_firewall" "internal_communication" {
  name    = var.compute_allow_internal_communication
  network = google_compute_network.vpc_network.self_link

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

  source_ranges = var.source_ranges_internal_comm
}

resource "google_compute_firewall" "health_check_firewall_rule" {
  name    = "q-health-check-firewall-rule-vaibhav"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = var.health_check_ports
  }

  source_ranges = ["0.0.0.0/0"]
}

# C. Creating a Compute Engine VM and
# D. Install nginx on the VM using start-up scripts
resource "google_compute_instance" "q-terraform-vm" {
  name         = "q-terraform-instance-vaibhav"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.subnet_us_central1.name

    access_config {
      // No external IP address
    }
  }

  metadata_startup_script = var.metadata_startup_script

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  tags = ["http-server"]
}

# E. Create an unmanaged MIG with the above VM
resource "google_compute_instance_group" "q_umig" {
  name        = "q-umig"
  description = "Terraform Unmanagend Instance Group"
  network     = google_compute_network.vpc_network.self_link

  instances = [google_compute_instance.q-terraform-vm.self_link]
}

# F. Create an HTTP load balancer and attach the UMIG as backend.
resource "google_compute_http_health_check" "q_health_check" {
  name               = "q-health-check"
  port               = 80
  request_path       = "/"
  check_interval_sec = 10
}

resource "google_compute_backend_service" "q_backend_service" {
  name        = "q-backend-service"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 10
  health_checks = [google_compute_http_health_check.q_health_check.self_link]
  backend {
    group = google_compute_instance_group.q_umig.self_link
  }
}