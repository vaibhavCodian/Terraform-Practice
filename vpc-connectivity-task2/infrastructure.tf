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
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc1.self_link
}

resource "google_compute_subnetwork" "subnet2" {
  name          = "subnet2"
  ip_cidr_range = "10.0.2.0/24"
  network       = google_compute_network.vpc2.self_link
}

#  Create GCE instance

resource "google_compute_instance" "vm1" {
  name         = "vm1"
  machine_type = "f1-micro"
  zone         = "us-central1-a"
  tags = ["vm1"]

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network    = google_compute_network.vpc1.self_link
    subnetwork = google_compute_subnetwork.subnet1.self_link
  }
}

resource "google_compute_instance" "vm2" {
  name         = "vm2"
  machine_type = "f1-micro"
  zone         = "us-central1-a"

  tags = ["vm2"]

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network    = google_compute_network.vpc2.self_link
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

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_ssh_traffic-2" {
  name    = "allow-ssh-traffic-2"
  network = google_compute_network.vpc2.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Allow traffic from VM1 to VM2
resource "google_compute_firewall" "allow_icmp_traffic_from_vm1_to_vm2" {
  name    = "allow-icmp-traffic-from-vm1-to-vm2"
  network = google_compute_network.vpc1.name

  allow {
    protocol = "icmp"
  }

  source_ranges = [google_compute_subnetwork.subnet1.ip_cidr_range]
  target_tags   = ["vm2"]
}

# Deny traffic from VM2 to VM1
resource "google_compute_firewall" "deny_icmp_traffic_from_vm2_to_vm1" {
  name    = "deny-icmp-traffic-from-vm2-to-vm1"
  network = google_compute_network.vpc2.name

  deny {
    protocol = "icmp"
  }

  source_ranges = [google_compute_subnetwork.subnet2.ip_cidr_range]
  target_tags   = ["vm1"]
}


# HA VPN in Gateway Creation

resource "google_compute_ha_vpn_gateway" "gateway1" {
  name    = "vpn-gateway1"
  network = google_compute_network.vpc1.self_link
}

resource "google_compute_ha_vpn_gateway" "gateway2" {
  name    = "vpn-gateway2"
  network = google_compute_network.vpc2.self_link
}


# external IP addresses for VPN
# below block is used to reserves a new address, and then you tell the VPN gateway to use that address.

resource "google_compute_address" "address1" {
  name = "vpn-address1"
}

resource "google_compute_address" "address2" {
  name = "vpn-address2"
}

# Sleep 60s to wait for the creation of VPN Gateway....

resource "time_sleep" "wait_60_seconds" {
  depends_on = [google_compute_ha_vpn_gateway.gateway1, google_compute_ha_vpn_gateway.gateway2]
  create_duration = "60s"
}


resource "google_compute_router" "router1" {
  name    = "router1"
  network = google_compute_network.vpc1.name
  region  = "us-central1"
}

resource "google_compute_router_interface" "interface1" {
  name       = "interface1"
  router     = google_compute_router.router1.name
  region     = google_compute_router.router1.region
  ip_range   = "169.254.0.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel1to2.id
}

resource "google_compute_router" "router2" {
  name    = "router2"
  network = google_compute_network.vpc2.name
  region  = "us-central1"
}

resource "google_compute_router_interface" "interface2" {
  name       = "interface2"
  router     = google_compute_router.router2.name
  region     = google_compute_router.router2.region
  ip_range   = "169.254.1.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel2to1.id
}


# VPN Tunnel On Each Of The Direction

resource "google_compute_vpn_tunnel" "tunnel1to2" {
  name                  = "tunnel1to2"
  region                = "us-central1"
  shared_secret         = "gcprocks"
  router                = google_compute_router.router1.name
  vpn_gateway           = google_compute_ha_vpn_gateway.gateway1.id
  vpn_gateway_interface = 0
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.gateway2.self_link
  depends_on = [
    # google_compute_forwarding_rule.fr1,
    time_sleep.wait_60_seconds,
    google_compute_ha_vpn_gateway.gateway1
  ]
}

resource "google_compute_vpn_tunnel" "tunnel2to1" {
  name                  = "tunnel2to1"
  region                = "us-central1"
  shared_secret         = "gcprocks"
  router                = google_compute_router.router2.name
  vpn_gateway           = google_compute_ha_vpn_gateway.gateway2.id
  vpn_gateway_interface = 0
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.gateway1.self_link
  depends_on = [
    # google_compute_forwarding_rule.fr1,
    time_sleep.wait_60_seconds,
    google_compute_ha_vpn_gateway.gateway2
  ]
}



resource "google_compute_router_peer" "peer1to2" {
  name                      = "peer1to2"
  router                    = google_compute_router.router1.name
  region                    = google_compute_router.router1.region
  peer_ip_address           = "169.254.0.2"
  peer_asn                  = 65002
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.interface1.name
}

resource "google_compute_router_peer" "peer2to1" {
  name                      = "peer2to1"
  router                    = google_compute_router.router2.name
  region                    = google_compute_router.router2.region
  peer_ip_address           = "169.254.1.2"
  peer_asn                  = 65001
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.interface2.name
}

