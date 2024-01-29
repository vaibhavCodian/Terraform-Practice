provider "google" {
  project         = "prj-inframod-pe-training-0124"
  region = "us-central-1"
  zone = "us-central1-a"
  impersonate_service_account = var.terraform_service_account
}

# resource google_storage_bucket "q-terraform-state-vaibhav-21" {
#   name = "q-terraform-state-vaibhav"  
#   location      = "us-central1" 
# }

# terraform {
#   backend "gcs" {
#     bucket = "q-terraform-state-vaibhav"
#     prefix = "1"
#     impersonate_service_account = "q-petraining-tf-sa@prj-inframod-pe-training-0124.iam.gserviceaccount.com"
#   }
# }
