provider "google" {
  project                     = "terraform-practice-412313"
  region                      = "us-central1"
  zone                        = "us-central1-a"
  impersonate_service_account = var.terraform_service_account
}
