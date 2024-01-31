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
variable "remote_state_bucket" {
  type        = string
  description = "Name of the storage bucket for remote state. Ensure that this name hase to be unique"
}

variable "dataset" {
  type = string
  default = "q_terraform_vabhav_db"
}

variable "table" {
  type = string
  default = "table-terraform-vaibhav"
}

variable "schema_file" {
  type = string
  default = "schema.json"
}
