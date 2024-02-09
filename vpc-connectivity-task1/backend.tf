# terraform {
#   backend "gcs" {
#     bucket = "q-inframod-pe-training-tf-state-bkt"
#     prefix = "q-terraform-vaibhav/1"
#     impersonate_service_account = "q-petraining-tf-sa@prj-inframod-pe-training-0124.iam.gserviceaccount.com"
#   }
# }


terraform {
  backend "gcs" {
    bucket = "q-inframod-pe-training-tf-state-bkt-2"
    prefix = "state/vpc-connectivity-task1"
    # impersonate_service_account = "terraform-gservice@terraform-practice-412313.iam.gserviceaccount.com"
  }
}