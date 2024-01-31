resource "google_bigquery_dataset" "dataset" {
  dataset_id = var.dataset
}


resource "google_bigquery_table" "table" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = var.table
  schema = file(var.schema_file)
}