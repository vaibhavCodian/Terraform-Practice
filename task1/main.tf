terraform {
  required_providers {
    google = {
      version = "~> 4.7.0"
    }
  }
}




terraform {
  backend "gcs" {
    bucket = "q-inframod-pe-training-tf-state-bkt-2"
    prefix = "q-terraform-vaibhav/1"
    impersonate_service_account = "terraform-practice-sa@terraform-practice-412313.iam.gserviceaccount.com"
  }
}

