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

variable "image" {
  default = "debian-cloud/debian-11"
}

variable "vpcs" {
  type = list(object({
    name = string
  }))
  default = [
    {
      name = "vpc-a"
    },
    {
      name = "vpc-b"
    },
    {
      name = "vpc-c"
    },
    {
      name = "vpc-d"
    },

  ]
}
