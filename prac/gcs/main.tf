resource "google_storage_bucket" "GCS-1" {

  name = "tf-practice-gcs"
  storage_class = "STANDARD"
  location = "us-central1"

  labels = {
    "env" = "tf_env"
    "dep" = "complience"
  }
  uniform_bucket_level_access = true  

  lifecycle_rule {
    
    condition {
      age = 5
    }

    action {
      type = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }

  retention_policy {
    is_locked = true
    retention_period = 87000
  }
  
}

resource "google_storage_bucket_object" "picture" {

  name = "vodafone_logo"
  bucket = google_storage_bucket.GCS-1.name
  source = "sample.txt"

}
