resource "google_sql_database_instance" "default" {
  name                = var.sql_database_instance_name
  region              = var.region
  database_version    = var.database_version
  deletion_protection = var.database_deletion_protection

  settings {
    tier = var.database_tier

    ip_configuration {
      ipv4_enabled    = var.ip_configuration_ipv4_enabled
      private_network = google_service_networking_connection.private_vpc_connection.network
    }


    dynamic "database_flags" {
      # for_each = {
      #   log_disconnections = var.database_flags_log_disconnection,
      #   log_statement      = var.database_flags_log_statement,
      #   log_temp_files     = var.database_log_temp_files,
      # }
      for_each = var.database_flags
      
      content {
        name  = database_flags.key
        value = database_flags.value
      }
    }
  }
}

resource "google_compute_network" "sql-default" {
  name                    = var.database_network_name
  auto_create_subnetworks = var.database_network_auto_create
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network = google_compute_network.sql-default.self_link

  service = var.database_network_connection_service

  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_compute_global_address" "private_ip_address" {
  name          = var.database_compute_global_address_name
  purpose       = var.database_compute_global_address_purpose
  address_type  = var.database_compute_global_address_type
  prefix_length = var.database_compute_global_address_prefix_length

  network = google_compute_network.sql-default.self_link
}
