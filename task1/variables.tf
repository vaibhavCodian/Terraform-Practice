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
variable "vpc_network_autocreate" {
  type = bool
  default = false
}

variable "subnet_name" {
  default = "q-terraform-subnetwork-vaibhav"
}

variable "ip_cidr_range" {
  default = "10.0.0.0/16"
}

variable "tcp" {
  default = "tcp"
}

variable "udp" {
  default = "udp"
}

variable "icmp" {
  default = "icmp"
}

variable "HTTP" {
  default = "HTTP"
}


variable "allow_iap_ports" {
  default = ["22"]
}

variable "allow_all_ports" {
  default = ["0-65535"]
}

variable "source_ranges_iap" {
  default = ["0.0.0.0/0"]
}

variable "source_ranges_internal_comm" {
  default = ["10.0.0.0/16"]
}

variable "health_check_name" {
  default = "q-health-check"
}

variable "health_check_source" {
  default = ["0.0.0.0/0"]
}

variable "health_check_ports" {
  default = ["80"]
}

variable "health_check_request_path" {
  default = "/"
}

variable "health_check_interval_sec" {
  default = 10
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

variable "health_check_firewall_rule_name" {
  default = "q-health-check-firewall-rule-vaibhav"
}

variable "compute_instance_name" {
  default = "q-terraform-instance-vaibhav"
}

variable "service_account_scopes" {
  default = ["https://www.googleapis.com/auth/cloud-platform"]
}

variable "compute_instance_mig_name" {
  default = "q-umig"
}

variable "compute_backend_service_name" {
  default = "q-backend-service"
}

variable "compute_backend_service_port_name" {
  default = "http"
}

variable "compute_backend_service_timeout_sec" {
  default = 10
}

variable "url_map_name" {
  default = "q-url-map"
}

variable "target_http_proxy_name" {
  default = "q-target-http-proxy"
}

variable "forwarding_rule_name" {
  default = "q-forwarding-rule"
}

variable "forwarding_rule_port_range" {
  default = "80"
}