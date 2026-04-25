variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names (e.g., 'demo', 'prod')"
  type        = string
  default     = "demo"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.name_prefix))
    error_message = "Name prefix must start with lowercase letter and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be 'dev', 'staging', or 'prod'."
  }
}

variable "enable_firewall_rules" {
  description = "Enable firewall rules for Cloud SQL access"
  type        = bool
  default     = true
}

variable "allowed_source_ranges" {
  description = "CIDR ranges allowed to access Cloud SQL"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # WARNING: Restrict this in production!
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15"
}

variable "database_tier" {
  description = "Cloud SQL machine type"
  type        = string
  default     = "db-f1-micro"
}

variable "cloud_run_image" {
  description = "Cloud Run container image URI"
  type        = string
  default     = "gcr.io/cloudrun/hello"
}

variable "cloud_run_memory" {
  description = "Cloud Run memory allocation (MB)"
  type        = number
  default     = 256
}

variable "labels" {
  description = "Common labels for all resources"
  type        = map(string)
  default = {
    project     = "gcp-postgres-terraform-example"
    managed_by  = "terraform"
    environment = "example"
  }
}
