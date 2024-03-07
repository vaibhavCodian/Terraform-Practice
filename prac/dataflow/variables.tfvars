dataflow_jobs = {
  dataflow_job_1 = {
    name   = "dataflow-job-1"
    project = "terraform-practice-412313"
    region = "me-central1"
    template_gcs_path = "gs://dataflow-templates/latest/Word_Count"
    temp_gcs_location = "gs://temp-df-2024-bkt/tmp/"
    parameters = {
      inputFile = "gs://dataflow-samples/shakespeare/kinglear.txt"
      output = "gs://temp-df-2024-bkt/results/output"
    }
  }
  dataflow_job_2 = {
    name   = "dataflow-job-2"
    project = "terraform-practice-412313"
    region = "me-central1"
    template_gcs_path = "gs://dataflow-templates/latest/Word_Count"
    temp_gcs_location = "gs://temp-df-2024-bkt/tmp/"
    parameters = {
      inputFile = "gs://dataflow-samples/shakespeare/othello.txt"
      output = "gs://temp-df-2024-bkt/results/output"
    }
  }
}