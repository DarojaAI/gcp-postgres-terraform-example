# Service Account for Terraform
resource "google_service_account" "terraform" {
  account_id   = "${var.name_prefix}-terraform-sa"
  display_name = "Terraform Service Account"
  description  = "Service account used by Terraform for deployment"
}

# Service Account for PostgreSQL operations
resource "google_service_account" "postgres_app" {
  account_id   = "${var.name_prefix}-postgres-app"
  display_name = "PostgreSQL App Service Account"
  description  = "Service account for applications connecting to Cloud SQL"
}

# Cloud SQL Instance
resource "google_sql_database_instance" "postgres" {
  name             = "${var.name_prefix}-postgres-${var.environment}"
  database_version = "POSTGRES_${var.postgres_version}"
  region           = var.region

  settings {
    tier              = var.database_tier
    availability_type = "REGIONAL"
    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      backup_retention_settings {
        retained_backups = 30
        retention_unit   = "COUNT"
      }
    }
    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.default.id
      require_ssl     = true
    }
    database_flags {
      name  = "cloudsql_iam_authentication"
      value = "on"
    }
  }

  deletion_protection = false

  labels = var.labels
}

# PostgreSQL Database
resource "google_sql_database" "main" {
  name     = "analytics"
  instance = google_sql_database_instance.postgres.name
}

# PostgreSQL User (app)
resource "google_sql_user" "app_user" {
  name     = "app_user"
  instance = google_sql_database_instance.postgres.name
  type     = "BUILT_IN"
}

# VPC Network
resource "google_compute_network" "default" {
  name                    = "${var.name_prefix}-network"
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "default" {
  name          = "${var.name_prefix}-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.default.id

  private_ip_google_access = true
}

# Private Service Connection for Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.name_prefix}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.default.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.default.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# Firewall Rules (Optional)
resource "google_compute_firewall" "allow_cloud_run" {
  count   = var.enable_firewall_rules ? 1 : 0
  name    = "${var.name_prefix}-allow-postgres"
  network = google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = var.allowed_source_ranges
  target_tags   = ["postgres-client"]
}

# Cloud Run Service
resource "google_cloud_run_service" "api" {
  name     = "${var.name_prefix}-api"
  location = var.region

  template {
    spec {
      containers {
        image = var.cloud_run_image
        env {
          name  = "DATABASE_URL"
          value = "postgresql://${google_sql_user.app_user.name}@${google_sql_database_instance.postgres.connection_name}/analytics"
        }
      }
      service_account_name = google_service_account.postgres_app.email
      memory = "${var.cloud_run_memory}Mi"
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

# IAM: Allow Cloud Run service account to connect to Cloud SQL
resource "google_project_iam_member" "cloud_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.postgres_app.email}"
}

# IAM: Allow Cloud Run service account to use IAM auth
resource "google_project_iam_member" "iam_db_user" {
  project = var.project_id
  role    = "roles/cloudsql.instanceUser"
  member  = "serviceAccount:${google_service_account.postgres_app.email}"
}

# Allow unauthenticated invocations to Cloud Run (for demo)
resource "google_cloud_run_service_iam_member" "noauth" {
  service       = google_cloud_run_service.api.name
  location      = google_cloud_run_service.api.location
  role          = "roles/run.invoker"
  member        = "allUsers"
}
