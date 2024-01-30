terraform {
  required_providers {
    google = {
      version = "~> 4.7.0"
    }
  }
}

provider "google" {
  project                     = "terraform-practice-412313"
  region                      = "us-central1"
  zone                        = "us-central1-a"
  impersonate_service_account = "terraform-practice-sa@terraform-practice-412313.iam.gserviceaccount.com"
}


terraform {
  backend "gcs" {
    bucket = "q-inframod-pe-training-tf-state-bkt-2"
    prefix = "state/bigq"
  }
}