resource "google_sql_database_instance" "default" {
  name             = "q-terraform-vaibhav-sql-instance"
  region           = "us-central1"
  database_version = "POSTGRES_14"
  deletion_protection = false

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_service_networking_connection.private_vpc_connection.network
    }

    database_flags {
      name  = "log_disconnections"
      value = "on"
    } # <-- logs the end of each session, including the session duration.

    database_flags { 
      name  = "log_statement"
      value = "ddl"
    } # <-- Controls which SQL statements are logged. 

    database_flags {
      name  = "log_temp_files"
      value = "0"
    } # <-- flag logs the use of temprory files by pg

  }
}

resource "google_compute_network" "sql-default" {
  name                    = "sql-default"
  auto_create_subnetworks = false
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.sql-default.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.sql-default.self_link
}
