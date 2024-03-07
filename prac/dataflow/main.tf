# Creates the Dataflow jobs; iterate over each element in the dataflow_jobs variable.


resource "google_dataflow_job" "dataflow_job" {
  for_each = var.dataflow_jobs

  name    = each.value.name
  project = each.value.project
  region  = each.value.region
  template_gcs_path = each.value.template_gcs_path
  temp_gcs_location = each.value.temp_gcs_location

  parameters = each.value.parameters
}