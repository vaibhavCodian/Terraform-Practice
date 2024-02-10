
// Create VPC's
resource "google_compute_network" "vpc_network1" {
  name                    = "vpc-network1"
  auto_create_subnetworks = false
}

resource "google_compute_network" "vpc_network2" {
  name                    = "vpc-network2"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet1_vpc_network1" {
  name          = "subnet1-vpc-network1"
  region        = "us-central1"
  ip_cidr_range = "10.0.0.0/16"
  network       = google_compute_network.vpc_network1.self_link
}

// Create Subnet's 
resource "google_compute_subnetwork" "subnet2_vpc_network1" {
  name          = "subnet2-vpc-network1"
  region        = "us-central1"
  ip_cidr_range = "10.1.0.0/16"
  network       = google_compute_network.vpc_network1.self_link
}

resource "google_compute_subnetwork" "subnet_vpc_network2" {
  name          = "subnet-vpc-network2"
  region        = "us-central1"
  ip_cidr_range = "10.2.0.0/16"
  network       = google_compute_network.vpc_network2.self_link
}

// Create a VM's in each subnet
resource "google_compute_instance" "vm1" {
  name         = "vm1"
  machine_type = "f1-micro"
  zone         = "us-central1-b"

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet1_vpc_network1.self_link
  }
}

resource "google_compute_instance" "vm2" {
  name         = "vm2"
  machine_type = "f1-micro"
  zone         = "us-central1-b"

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet2_vpc_network1.self_link
  }
}

resource "google_compute_instance" "vm3" {
  name         = "vm3"
  machine_type = "f1-micro"
  zone         = "us-central1-b"

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_vpc_network2.self_link
  }
}

# REserve Static IP address for both vpc
resource "google_compute_address" "vpn_static_ip1" {
  name   = "vpn-static-ip1"
  region = "us-central1"
}
resource "google_compute_address" "vpn_static_ip2" {
  name   = "vpn-static-ip2"
  region = "us-central1"
}

// Create a Google Cloud Router in each network

resource "google_compute_router" "router1" {
  name    = "router1"
  network = google_compute_network.vpc_network1.self_link
  region  = "us-central1"
}

resource "google_compute_router" "router2" {
  name    = "router2"
  network = google_compute_network.vpc_network2.self_link
  region  = "us-central1"
}

# Create VPN gateways in both VPCs
resource "google_compute_vpn_gateway" "gateway_vpc1" {
  name    = "vpn-gateway-vpc1"
  network = google_compute_network.vpc_network1.self_link
  region  = "us-central1"
}

resource "google_compute_vpn_gateway" "gateway_vpc2" {
  name    = "vpn-gateway-vpc2"
  network = google_compute_network.vpc_network2.self_link
  region  = "us-central1"
}

# Create VPN Forwarding Rule   ... ?
# VPN Forwarding Rule ESP

# resource "google_compute_forwarding_rule" "vpn-classic-fr1" {
#   name        = "vpn-classic-fr1"
#   ip_protocol = "ESP"
#   region      = "us-central1"
#   ip_address  = google_compute_address.vpn_static_ip1.address
#   target      = google_compute_vpn_gateway.gateway_vpc1.id
# }

# resource "google_compute_forwarding_rule" "vpn-classic-udp500-fr1" {
#   name        = "vpn-classic-500-fr1"
#   ip_protocol = "UDP"
#   port_range = "500"
#   region      = "us-central1"
#   ip_address  = google_compute_address.vpn_static_ip1.address
#   target      = google_compute_vpn_gateway.gateway_vpc1.id
# }

# resource "google_compute_forwarding_rule" "vpn-classic-udp4500-fr1" {
#   name        = "vpn-classic-4500-fr1"
#   ip_protocol = "UDP"
#   port_range = "4500"
#   region      = "us-central1"
#   ip_address  = google_compute_address.vpn_static_ip1.address
#   target      = google_compute_vpn_gateway.gateway_vpc1.id
# }

# # ------------

# resource "google_compute_forwarding_rule" "vpn-classic-fr2" {
#   name        = "vpn-classic-fr2"
#   ip_protocol = "ESP"
#   region      = "us-central1"
#   ip_address  = google_compute_address.vpn_static_ip2.address
#   target      = google_compute_vpn_gateway.gateway_vpc2.id
# }

# resource "google_compute_forwarding_rule" "vpn-classic-udp500-fr2" {
#   name        = "vpn-classic-500-fr2"
#   ip_protocol = "UDP"
#   port_range = "500"
#   region      = "us-central1"
#   ip_address  = google_compute_address.vpn_static_ip2.address
#   target      = google_compute_vpn_gateway.gateway_vpc2.id
# }

# resource "google_compute_forwarding_rule" "vpn-classic-udp4500-fr2" {
#   name        = "vpn-classic-4500-fr2"
#   ip_protocol = "UDP"
#   port_range = "4500"
#   region      = "us-central1"
#   ip_address  = google_compute_address.vpn_static_ip2.address
#   target      = google_compute_vpn_gateway.gateway_vpc2.id
# }


# TEST --> creation of tunnel

# resource "google_compute_vpn_tunnel" "vpn-tunnel-classic1" {
#   depends_on = [
#     google_compute_forwarding_rule.vpn-classic-fr1,
#     google_compute_forwarding_rule.vpn-classic-udp500-fr1,
#     google_compute_forwarding_rule.vpn-classic-udp4500-fr1,
    
#     google_compute_forwarding_rule.vpn-classic-fr2,
#     google_compute_forwarding_rule.vpn-classic-udp500-fr2,
#     google_compute_forwarding_rule.vpn-classic-udp4500-fr2,

#     google_compute_vpn_gateway.gateway_vpc1,
#     google_compute_vpn_gateway.gateway_vpc2
#   ]

#   name               = "vpn-tunnel-classic1"
#   region             = "us-central1"
#   peer_ip            = google_compute_address.vpn_static_ip1.address
#   shared_secret      = "gcprocks"
#   target_vpn_gateway = google_compute_vpn_gateway.gateway_vpc2.id
#   router             = google_compute_router.router1.name
#  }


# ------------------------------------------------------------
# Tunnel Configuration Done Throught WEB_Interface...
# --------------------------------------------------------------





# networking configuraton

resource "google_compute_firewall" "allow_ssh_traffic-1" {
  name    = "allow-ssh-traffic-1"
  network = google_compute_network.vpc_network1.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_ssh_traffic-2" {
  name    = "allow-ssh-traffic-2"
  network = google_compute_network.vpc_network2.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Allow internal-traffic for icmp
resource "google_compute_firewall" "allow_icmp_traffic_internal1" {
  name    = "allow-icmp-traffic-internal1"
  network = google_compute_network.vpc_network1.name

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    google_compute_subnetwork.subnet1_vpc_network1.ip_cidr_range,
    google_compute_subnetwork.subnet2_vpc_network1.ip_cidr_range,
    google_compute_subnetwork.subnet_vpc_network2.ip_cidr_range,
    "0.0.0.0/0"
  ]
}

resource "google_compute_firewall" "allow_icmp_traffic_internal2" {
  name    = "allow-icmp-traffic-internal2"
  network = google_compute_network.vpc_network2.name

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    google_compute_subnetwork.subnet1_vpc_network1.ip_cidr_range,
    google_compute_subnetwork.subnet2_vpc_network1.ip_cidr_range,
    google_compute_subnetwork.subnet_vpc_network2.ip_cidr_range,
    "0.0.0.0/0"
  ]
}


# Tunnel Creation Test -------------------  RETIRED


# Sleep 60s to wait for the creation of VPN Gateway....

# resource "time_sleep" "wait_60_seconds" {
#   depends_on      = [google_compute_vpn_gateway.gateway_vpc1, google_compute_vpn_gateway.gateway_vpc2]
#   create_duration = "60s"
# }

# VPN Tunnel On Each Of The Direction

# resource "google_compute_vpn_tunnel" "tunnel1to2" {
#   name          = "tunnel1to2"
#   region        = "us-central1"
#   shared_secret = "gcprocks"
#   # router                = google_compute_router.router1.name
#   vpn_gateway           = google_compute_vpn_gateway.gateway_vpc1.id
#   vpn_gateway_interface = 0
#   peer_gcp_gateway      = google_compute_vpn_gateway.gateway_vpc2.self_link
#   depends_on = [
#     # time_sleep.wait_60_seconds,
#     google_compute_vpn_gateway.gateway_vpc1,
#     google_compute_vpn_gateway.gateway_vpc2,   
#   ]
# }

# resource "google_compute_vpn_tunnel" "tunnel2to1" {
#   name          = "tunnel2to1"
#   region        = "us-central1"
#   shared_secret = "gcprocks"
#   # router                = google_compute_router.router2.name
#   vpn_gateway           = google_compute_vpn_gateway.gateway_vpc2.id
#   vpn_gateway_interface = 0
#   peer_gcp_gateway      = google_compute_vpn_gateway.gateway_vpc1.self_link
#   depends_on = [
#     # time_sleep.wait_60_seconds,
#     google_compute_vpn_gateway.gateway_vpc2,
#     google_compute_vpn_gateway.gateway_vpc1,
#   ]
# }
