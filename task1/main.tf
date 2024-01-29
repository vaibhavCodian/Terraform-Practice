terraform {
  required_providers {
    google = {
      version = "~> 4.7.0"
    }
  }
}




# terraform {
#   backend "gcs" {
#     bucket = "q-inframod-pe-training-tf-state-bkt"
#     prefix = "q-terraform-vaibhav/1"
#     impersonate_service_account = "q-petraining-tf-sa@prj-inframod-pe-training-0124.iam.gserviceaccount.com"
#   }
# }

# terraform {
#   backend "gcs" {
#     bucket = "q-terraform-vaibhav"
#     prefix = "1"
#     impersonate_service_account = "q-petraining-tf-sa@prj-inframod-pe-training-0124.iam.gserviceaccount.com"
#   }
# }

