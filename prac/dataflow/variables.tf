variable "dataflow_jobs" {
  type = map(object({
    name             = string
    project          = string
    region           = string
    template_gcs_path = string
    temp_gcs_location = string
    parameters       = map(string)
  }))
}