variable "terraform_service_account" {
  type        = string
  description = "email adress of the service account used for terraform"

}

variable "project_id" {
  type        = string
  description = "ID of the project in scope"
}

variable "region" {
  type        = string
  description = "default region"
  default = "us-central1"
}


variable "remote_state_bucket" {
  type        = string
  description = "Name of the storage bucket for remote state. Ensure that this name hase to be unique"
}

# Infrastructure Variables

variable "sql_database_instance_name" {
  type = string
  default = "q-terraform-vaibhav-sql-instance"
}

variable "database_version" {
  type = string
  default = "POSTGRES_14"
}

variable "database_deletion_protection" {
  type = bool
  default = false
}

variable "database_tier" {
  type = string
  default = "db-f1-micro"
}

variable "ip_configuration_ipv4_enabled" {
  type = bool
  default = false
}

# database flags variables

# variable database_flags_log_disconnection {
#   type = string
#   default = "on"
# }

# variable database_flags_log_statement {
#   type = string
#   default = "ddl"
# }

# variable "database_log_temp_files" {
#   type = string
#   default = "0"
# }

variable "database_flags" {
  type = map(string)
  # default = {
  #   log_disconnections = "on",
  #   log_statement      = "ddl",
  #   log_temp_files     = "0",
  # }
}
# database network varialbles

variable "database_network_name" {
  type = string
  default = "sql-default"
}

variable "database_network_auto_create" {
  type = bool
  default = false
}

variable "database_network_connection_service" {
  type = string
  default = "servicenetworking.googleapis.com"
}

variable "database_compute_global_address_name" {
  type = string
  default = "private-ip-address"
}

variable "database_compute_global_address_purpose" {
  type = string
  default = "VPC_PEERING"
}

variable "database_compute_global_address_type" {
  type = string
  default = "INTERNAL"
}

variable "database_compute_global_address_prefix_length" {
  type = number
  default = 16
}
