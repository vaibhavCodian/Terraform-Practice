# # Setup 2 VPCs

# resource "google_compute_network" "vpc1" {
#   name                    = "vpc1"
#   auto_create_subnetworks = false
# }

resource "google_compute_network" "vpc2" {
  name                    = "vpc2-2"
  auto_create_subnetworks = false
}

# # and 1 subnet

resource "google_compute_subnetwork" "vpc_2_subnet" {
  name          = "vpc-2-subnet"
  region        = "us-central1"
  ip_cidr_range = "10.0.0.0/16"
  network       = google_compute_network.vpc2.name
}

# # Setup Private Service Connect in VPC 1

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc2.self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc2.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# Setup Cloud SQL in VPC-1

# resource "google_sql_database_instance" "db_instance" {
#   name             = "database-instance"
#   database_version = "MYSQL_5_7"
#   region           = "us-central1"
#   deletion_protection = false
#   settings {
#     tier = "db-f1-micro"

#     ip_configuration {
#       private_network = google_compute_network.vpc1.self_link
#     }
#   }
# }

# # Create a VM in VPC-2 to Connect to Cloud SQL in VPC-1
# resource "google_compute_instance" "default" {
#   name         = "vm"
#   machine_type = "f1-micro"
#   zone         = "us-central1-a"

#   boot_disk {
#     initialize_params {
#       image = var.image
#     }
#   }

#   metadata_startup_script = "wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy && chmod +x cloud_sql_proxy && nohup ./cloud_sql_proxy -instances=${google_sql_database_instance.db_instance.connection_name}=tcp:5432 &"

#   network_interface {
#     network = google_compute_network.vpc2.self_link
#     subnetwork  = google_compute_subnetwork.vpc_2_subnet.self_link
#   }
# }

# # Firewall for ssh
# resource "google_compute_firewall" "allow_ssh_vpc_a" {
#   name    = "allow-ssh-vpc-a"
#   network = google_compute_network.vpc2.name

#   allow {
#     protocol = "tcp"
#     ports    = ["22"]
#   }
#   source_ranges = ["0.0.0.0/0"]
# }



