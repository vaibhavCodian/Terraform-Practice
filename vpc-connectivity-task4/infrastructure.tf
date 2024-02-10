# VPC Creation

resource "google_compute_network" "vpc_a" {
  name = "vpc-a"
  auto_create_subnetworks = false
}

resource "google_compute_network" "vpc_b" {
  name = "vpc-b"
  auto_create_subnetworks = false
}

resource "google_compute_network" "vpc_c" {
  name = "vpc-c"
  auto_create_subnetworks = false
}

resource "google_compute_network" "vpc_d" {
  name = "vpc-d"
  auto_create_subnetworks = false
}

# Subnet Creation

resource "google_compute_subnetwork" "vpc_a_subnet" {
  name = "vpc-a-subnet"
  region = "us-central1"
  ip_cidr_range = "10.1.0.0/16"
  network = google_compute_network.vpc_a.name
}

resource "google_compute_subnetwork" "vpc_b_subnet" {
  name = "vpc-b-subnet"
  region = "us-central1"
  ip_cidr_range = "10.2.0.0/16"
  network = google_compute_network.vpc_b.name
}

resource "google_compute_subnetwork" "vpc_c_subnet" {
  name = "vpc-c-subnet"
  region = "us-central1"
  ip_cidr_range = "10.3.0.0/16"
  network = google_compute_network.vpc_c.name
}

resource "google_compute_subnetwork" "vpc_d_subnet" {
  name = "vpc-d-subnet"
  region = "us-central1"
  ip_cidr_range = "10.4.0.0/16"
  network = google_compute_network.vpc_d.name
}

# Firewall Rules for SSH and ICMP

resource "google_compute_firewall" "allow_ssh_vpc_a" {
  name    = "allow-ssh-vpc-a"
  network = google_compute_network.vpc_a.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "allow_ssh_vpc_b" {
  name    = "allow-ssh-vpc-b"
  network = google_compute_network.vpc_b.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "allow_ssh_vpc_c" {
  name    = "allow-ssh-vpc-c"
  network = google_compute_network.vpc_c.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "allow_ssh_vpc_d" {
  name    = "allow-ssh-vpc-d"
  network = google_compute_network.vpc_d.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_icmp_a" {
  name    = "allow-icmp-a"
  network = google_compute_network.vpc_a.name

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_icmp_b" {
  name    = "allow-icmp-b"
  network = google_compute_network.vpc_b.name

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_icmp_c" {
  name    = "allow-icmp-c"
  network = google_compute_network.vpc_c.name

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_icmp_d" {
  name    = "allow-icmp-d"
  network = google_compute_network.vpc_d.name

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

# vpc-peering
resource "google_compute_network_peering" "vpc_b_to_vpc_c" {
  name          = "vpc-b-to-vpc-c"
  network       = google_compute_network.vpc_b.self_link
  peer_network  = google_compute_network.vpc_c.self_link
}

resource "google_compute_network_peering" "vpc_c_to_vpc_b" {
  name          = "vpc-c-to-vpc-b"
  network       = google_compute_network.vpc_c.self_link
  peer_network  = google_compute_network.vpc_b.self_link
}


# VM Creation

resource "google_compute_instance" "instance-a" {
  name = "instance-a"
  machine_type = "f1-micro"
  zone = "us-central1-a"

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = google_compute_network.vpc_a.self_link
    subnetwork = google_compute_subnetwork.vpc_a_subnet.self_link
  }
}
resource "google_compute_instance" "instance-b" {
  name = "instance-b"
  machine_type = "f1-micro"
  zone = "us-central1-a"

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = google_compute_network.vpc_b.self_link
    subnetwork = google_compute_subnetwork.vpc_b_subnet.self_link
  }
}
resource "google_compute_instance" "instance-c" {
  name = "instance-c"
  machine_type = "f1-micro"
  zone = "us-central1-a"

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = google_compute_network.vpc_c.self_link
    subnetwork = google_compute_subnetwork.vpc_c_subnet.self_link
  }
}
resource "google_compute_instance" "instance-d" {
  name = "instance-d"
  machine_type = "f1-micro"
  zone = "us-central1-a"

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = google_compute_network.vpc_d.self_link
    subnetwork = google_compute_subnetwork.vpc_d_subnet.self_link
  }
}
