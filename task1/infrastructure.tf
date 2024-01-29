
# A. Creating VPC and Subnet in US-central-1

resource "google_compute_network" "vpc_network" {
  name = "q-terraform-network-vaibhav"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_us_central1" {
  name          = "q-terraform-subnetwork-vaibhav"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.self_link
}

# B. Creating Firewall rules to allow IAP and Internal Comminications in the subnet

resource "google_compute_firewall" "allow_iap_firewall_rule" {
  name    = "q-allow-iap-firewall-rule-vaibhav"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "internal_communication" {
  name    = "q-internal-communication-vaibhav"
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

  source_ranges = ["10.0.0.0/16"]
}

resource "google_compute_firewall" "health_check_firewall_rule" {
  name    = "q-health-check-firewall-rule-vaibhav"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# C. Creating a Compute Engine VM and 
# D. Install nginx on the VM using start-up scripts

resource "google_compute_instance" "q-terraform-vm" {
  name         = "q-terraform-instance-vaibhav"
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
      // No external IP address4
    }
  }

  metadata_startup_script = "sudo apt-get update; sudo apt-get install -y nginx"

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


# F. Create a HTTP load balancer and attach the UMIG as backend.


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

# resource "google_compute_url_map" "q_url_map" {
#   name            = "q-url-map"
#   default_route_action {
#     backend_service = google_compute_backend_service.q_backend_service.self_link
#   }
# }

# resource "google_compute_target_http_proxy" "my_target_http_proxy" {
#   name    = "my-target-http-proxy"
#   url_map = google_compute_url_map.my_url_map.self_link
# }

# resource "google_compute_global_forwarding_rule" "my_forwarding_rule" {
#   name       = "my-forwarding-rule"
#   target     = google_compute_target_http_proxy.my_target_http_proxy.self_link
#   port_range = "80"
# }

