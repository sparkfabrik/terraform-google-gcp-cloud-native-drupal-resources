terraform {
  required_version = ">= 1.2"

  required_providers {
    # tflint-ignore: terraform_unused_required_providers
    google = {
      source  = "hashicorp/google"
      version = ">= 4.47.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.19"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}

provider "random" {
  # Configuration options
}

resource "google_compute_network" "private_network" {
  provider = google
  project  = var.my_project_id
  name     = "private-network"
}

resource "google_compute_global_address" "private_ip_address" {
  provider      = google
  project       = var.my_project_id
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.private_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google

  network = google_compute_network.private_network.id
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    google_compute_global_address.private_ip_address.name
  ]
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

# Create a CloudSQL MySQL 8 instance
resource "google_sql_database_instance" "instance" {
  provider            = google
  project             = var.my_project_id
  name                = "private-instance-${random_id.db_name_suffix.hex}"
  region              = var.my_region
  database_version    = "MYSQL_8_0"
  deletion_protection = false
  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]

  settings {
    disk_size = 10
    tier      = "db-f1-micro"
    backup_configuration {
      enabled = false
    }
    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.private_network.id
    }
  }
}

# Create admin credentials for MySQL.
resource "random_password" "admin_sql_user_password_mysql" {
  length           = 24
  special          = true
  override_special = "_~@"
}

resource "google_sql_user" "admin_user_mysql" {
  project  = var.my_project_id
  instance = google_sql_database_instance.instance.name
  name     = "admin"
  password = random_password.admin_sql_user_password_mysql.result
  host     = "%"
}

module "drupal_resources" {
  source                            = "sparkfabrik/gcp-cloud-native-drupal-resources/google"
  version                           = ">= 0.8.0"
  project_id                        = var.my_project_id
  region                            = var.my_region
  cloudsql_instance_name            = google_sql_database_instance.instance.name
  cloudsql_privileged_user_name     = google_sql_user.admin_user_mysql.name
  cloudsql_privileged_user_password = google_sql_user.admin_user_mysql.password
  drupal_projects_list              = var.my_drupal_projects_list
  global_tags                       = ["dev/viewer", "ops/editor"]
}
