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
}

variable "zone" {
  default = "us-central1-a"
}


variable "remote_state_bucket" {
  type        = string
  description = "Name of the storage bucket for remote state. Ensure that this name hase to be unique"
}

# Infrastructure Variables

# Define variables
variable "vpc_network_name" {
  default = "q-terraform-network-vaibhav"
}

variable "subnet_name" {
  default = "q-terraform-subnetwork-vaibhav"
}

variable "ip_cidr_range" {
  default = "10.0.0.0/16"
}


variable "allow_iap_ports" {
  default = ["22"]
}

variable "source_ranges_iap" {
  default = ["0.0.0.0/0"]
}

variable "source_ranges_internal_comm" {
  default = ["10.0.0.0/16"]
}

variable "health_check_ports" {
  default = ["80"]
}

variable compute_allow_iap_firewall_name {
  default = "q-allow-iap-firewall-rule-vaibhav"
}

variable "compute_allow_internal_communication" {
  default = "q-internal-communication-vaibhav"
}

variable "machine_type" {
  default = "n1-standard-1"
}

variable "image" {
  default = "debian-cloud/debian-11"
}

variable "metadata_startup_script" {
  default = "sudo apt-get update; sudo apt-get install -y nginx"
}


