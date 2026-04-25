output "instance_connection_name" {
  description = "Cloud SQL instance connection name (PROJECT:REGION:INSTANCE)"
  value       = google_sql_database_instance.postgres.connection_name
}

output "instance_ip_address" {
  description = "Cloud SQL instance private IP address"
  value       = google_sql_database_instance.postgres.private_ip_address
}

output "instance_public_ip" {
  description = "Cloud SQL instance public IP address"
  value       = google_sql_database_instance.postgres.public_ip_address
}

output "cloud_run_service_url" {
  description = "Cloud Run service URL"
  value       = google_cloud_run_service.api.status[0].url
}

output "cloud_run_service_name" {
  description = "Cloud Run service name"
  value       = google_cloud_run_service.api.name
}

output "firewall_rules_created" {
  description = "Number of firewall rules created"
  value       = var.enable_firewall_rules ? 1 : 0
}

output "database_name" {
  description = "PostgreSQL database name"
  value       = google_sql_database.main.name
}

output "app_service_account" {
  description = "Service account email for Cloud Run"
  value       = google_service_account.postgres_app.email
}

output "network_id" {
  description = "VPC network ID"
  value       = google_compute_network.default.id
}

output "deployment_info" {
  description = "Deployment summary"
  value = {
    instance_connection_name = google_sql_database_instance.postgres.connection_name
    instance_ip              = google_sql_database_instance.postgres.private_ip_address
    cloud_run_url            = google_cloud_run_service.api.status[0].url
    firewall_rules           = var.enable_firewall_rules ? 1 : 0
    environment              = var.environment
    name_prefix              = var.name_prefix
  }
}
