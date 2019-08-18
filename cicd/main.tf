variable "PROJECT_ID" {
  type    = string
  default = "frozensake"
}

variable "region" {
  type    = string
  default = "northamerica-northeast1"
}

variable "zone" {
  type    = string
  default = "northamerica-northeast1a"
}

variable "service-key" {
  type    = string
  default = "./gcs-key.json"
}

variable "gitlab-db-user" {
  type    = string
  default = "gitlab"
}

provider "google" {
  credentials = "${file("${var.service-key}")}"
  project     = "${var.PROJECT_ID}"
  region      = "${var.region}"
  zone        = "${var.zone}"
}

resource "random_password" "db-password" {
  length  = 16
  special = true
}

resource "google_storage_bucket" "gitlab-uploads" {
  name      = "${var.PROJECT_ID}-gitlab-uploads"
  location  = "US"
  project   = "${var.PROJECT_ID}"

  /*labels {
    cost_center = "CICD"
    purpose     = "CICD"
  }*/
}
resource "google_storage_bucket" "gitlab-artifacts" {
  name      = "${var.PROJECT_ID}-gitlab-artifacts"
  location  = "US"
  project   = "${var.PROJECT_ID}"

  /*labels {
    cost_center = "CICD"
    purpose     = "CICD"
  }*/
}
resource "google_storage_bucket" "gitlab-lfs" {
  name      = "${var.PROJECT_ID}-gitlab-lfs"
  location  = "US"
  project   = "${var.PROJECT_ID}"

  /*labels {
    cost_center = "CICD"
    purpose     = "CICD"
  }*/
}
resource "google_storage_bucket" "gitlab-packages" {
  name      = "${var.PROJECT_ID}-gitlab-packages"
  location  = "US"
  project   = "${var.PROJECT_ID}"

  /*labels {
    cost_center = "CICD"
    purpose     = "CICD"
  }*/
}
resource "google_storage_bucket" "gitlab-registry" {
  name      = "${var.PROJECT_ID}-gitlab-registry"
  location  = "US"
  project   = "${var.PROJECT_ID}"

  /*labels {
    cost_center = "CICD"
    purpose     = "CICD"
  }*/
}

resource "google_compute_address" "gitlab-ip" {
  name = "gitlab-ip"

  /*labels {
    cost_center = "CICD"
    purpose     = "CICD"
  }*/
}

resource "google_compute_network" "gitlab-network" {
  name = "gitlab-network"
}

resource "google_compute_subnetwork" "gitlab-sql-db-net" {
  name = "gitlab-db-subnet"
  ip_cidr_range = "10.120.120.0/24"
  network = "${google_compute_network.gitlab-network.self_link}"
}

/*resource "google_compute_network_peering" "sql-to-gitlab" {

}*/

/*resource "google_compute_subnetwork" "gitlab-subnetwork" {

}*/

resource "google_sql_database_instance" "gitlab-master" {
  name             = "gitlab-master-instance"
  database_version = "POSTGRES_9_6"
  region           = "${var.region}"
  project          = "${var.PROJECT_ID}"

  settings {
    tier = "db-f1-micro"
  }

  /*user_labels {
    cost_center = "CICD"
    purpose     = "CICD"
  }*/
}

resource "google_sql_database" "gitlab-postgres" {
  name     = "gitlab-db"
  instance = "${google_sql_database_instance.gitlab-master.name}"
}

resource "google_redis_instance" "gitlab-redis" {
  name           = "gitlab-redis"
  display_name   = "gitlab-redis"
  tier           = "BASIC"
  memory_size_gb = 2

  location_id        = "${var.zone}"
  authorized_network = "${google_compute_network.gitlab-network.self_link}"

  /*labels = {
    cost_center = "CICD"
    purpose     = "CICD"
  }*/

  #redis_version not included, thus using latest supported
}

resource "google_container_cluster" "gitlab-cluster" {
  name         = "gitlab-kubernetes-cluster"
  location     = "${var.zone}"

  node_config {
    machine_type = "n1-standard-4"
  }

  ip_allocation_policy {
    use_ip_aliases = true
  }
}

data "local_file" "pd-ssd-storage" {
  filename = "./pd-ssd-storage.yaml"
}

#resource kubectl_secret_1

data "local_file" "rails" {
  filename = "./rails.yaml"
}

#resource kubectl_secret_2

#ansible?