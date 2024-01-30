resource "google_sql_database_instance" "mysql-from-tf" {
    name = "mysql-from-tf"
    deletion_protection = false
    database_version = "POSTGRES_15"
    region = "us-central1"

    settings {
      tier = "db-f1-micro"
    }
}

resource "google_sql_user" "myuser" {
  name = "Vaibhav"
  password = "pass@1234"  # <<--- Implement password protection here

  instance = google_sql_database_instance.mysql-from-tf.name

}