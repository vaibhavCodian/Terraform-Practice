service_accounts = {
  service_account_1 = {
    account_id   = "vaibhav-sa"
    display_name = "Service Account for Vaibhav"
    description  = "Description for Service Account for Vaibhav"
    project      = "terraform-practice-412313"
    project_roles        = ["roles/storage.objectAdmin"]
  }
  service_account_2 = {
    account_id   = "satyam-sa"
    display_name = "Service Account for Satyam"
    description  = "Description for Service Account for Satyam"
    project      = "terraform-practice-412313"
    project_roles        = ["roles/storage.objectViewer"]
  }
}
