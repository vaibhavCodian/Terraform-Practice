
# A. Creating VPC and Subnet in US-central-1
resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_network_name
  auto_create_subnetworks = var.vpc_network_autocreate
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
    protocol = var.tcp
    ports    = var.allow_iap_ports
  }

  source_ranges = var.source_ranges_iap
}

resource "google_compute_firewall" "internal_communication" {
  name    = var.compute_allow_internal_communication
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = var.icmp
  }

  allow {
    protocol = var.tcp
    ports    = var.allow_all_ports
  }

  allow {
    protocol = var.udp
    ports    = var.allow_all_ports
  }

  source_ranges = var.source_ranges_internal_comm
}

resource "google_compute_firewall" "health_check_firewall_rule" {
  name    = var.health_check_firewall_rule_name
  network = google_compute_network.vpc_network.name

  allow {
    protocol = var.tcp
    ports    = var.health_check_ports
  }

  source_ranges = var.health_check_source
}

# C. Creating a Compute Engine VM and
# D. Install nginx on the VM using start-up scripts
resource "google_compute_instance" "q-terraform-vm" {
  name         = var.compute_instance_name
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
    scopes = var.service_account_scopes
  }

}

# E. Create an unmanaged MIG with the above VM
resource "google_compute_instance_group" "q_umig" {
  name        = var.compute_instance_mig_name
  network     = google_compute_network.vpc_network.self_link

  instances = [google_compute_instance.q-terraform-vm.self_link]
}

# F. Create an HTTP load balancer and attach the UMIG as backend.
resource "google_compute_http_health_check" "q_health_check" {
  name               = var.health_check_name
  port               = var.health_check_ports
  request_path       = var.health_check_request_path
  check_interval_sec = var.health_check_interval_sec
}

resource "google_compute_backend_service" "q_backend_service" {
  name        = var.compute_backend_service_name
  protocol    = var.HTTP
  port_name   = var.compute_backend_service_port_name
  timeout_sec = var.compute_backend_service_timeout_sec
  health_checks = [google_compute_http_health_check.q_health_check.self_link]
  backend {
    group = google_compute_instance_group.q_umig.self_link
  }
}



resource "google_compute_url_map" "q_url_map" { 
  name            = var.url_map_name
  default_route_action {
    backend_service = google_compute_backend_service.q_backend_service.self_link
  }
}

resource "google_compute_target_http_proxy" "q_target_http_proxy" {
  name      = var.target_http_proxy_name
  url_map   = google_compute_url_map.q_url_map.self_link
}

resource "google_compute_global_forwarding_rule" "q_forwarding_rule" { # 
  name       = var.forwarding_rule_name
  target     = google_compute_target_http_proxy.q_target_http_proxy.self_link
  port_range = var.forwarding_rule_port_range
}
