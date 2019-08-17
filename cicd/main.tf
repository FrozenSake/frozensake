variable region {

}

variable zone {

}

resource random password {

}

variable service-key {

}

variable db-user {

}

provider "google" {
  credentials = "${file("*.json")}"
  project     = "${var.project}"
  region      = "${var.region}"
  zone        = "${var.zone}"
}

resource "gcp_storage_bucket" "${var.project}-uploads" {
  name      = "${var.project}-uploads"
  location  = "US"
  project   =  "${var.project}"
}
resource "gcp_storage_bucket" "${var.project}-artifacts" {
  name      = "${var.project}-artifacts"
  location  = "US"
  project   =  "${var.project}"
}
resource "gcp_storage_bucket" "${var.project}-lfs" {
  name      = "${var.project}-lfs"
  location  = "US"
  project   =  "${var.project}"
}
resource "gcp_storage_bucket" "${var.project}-packages" {
  name      = "${var.project}-packages"
  location  = "US"
  project   =  "${var.project}"
}
resource "gcp_storage_bucket" "${var.project}-registry" {
  name      = "${var.project}-registry"
  location  = "US"
  project   =  "${var.project}"
}

resource "google_compute_address" "sql_ip" {

}

resource "google_compute_network_peering" "sql-to-gitlab" {

}

resource "google_compute_network" "gitlab-network" {

}

/*resource "google_compute_subnetwork" "gitlab-subnetwork" {

}*/

resource "google_sql_database_instance" "gitlab-master" {
  name             = "gitlab-master-instance"
  database_version = "POSTGRES_9_6"
  region           = "${var.region}"
  project          = "${var.project}"

  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_database" "gitlab-postgres" {
  name     = "gitlab-db"
  instance = "${google_sql_database_instance.gitlab-master.name}"
}

resource "google_redis_instance" "gitlab-redis" {

}

resource "google_container_cluster" "gitlab-cluster" {

}

data "local_file" "pd-ssd-storage.yaml" {
  filename = "./pd-ssd-storage.yaml"
}

#resource kubectl_secret_1

data "local_file" "rails.yaml" {
  filename = "./rails.yaml"
}

#resource kubectl_secret_2

#ansible?

