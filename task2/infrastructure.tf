resource "google_bigquery_dataset" "dataset" {
  dataset_id = "q_terraform_vabhav_db"
}


resource "google_bigquery_table" "table" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "table-terraform-vaibhav"
  schema = file("schema.json")
}