# Customization Guide

How to adapt this example for your specific needs.

---

## Resource Naming

### Change All Resource Names
Edit `terraform/terraform.tfvars`:
```hcl
name_prefix = "myapp"  # Changes all resources
# Results in: myapp-postgres-dev, myapp-api, etc.
```

### Change Environment
```hcl
environment = "prod"  # dev, staging, prod
# Results in: demo-postgres-prod, demo-api-prod, etc.
```

---

## Database Configuration

### Larger Instance (Production)
```hcl
database_tier = "db-n1-standard-2"  # 1 CPU, 3.75 GB RAM
# Options: db-n1-standard-1, -2, -4, -16
#          db-n1-highmem-2, -4, -16
#          db-n1-highcpu-2, -4, -16
```

### PostgreSQL Version
```hcl
postgres_version = "16"  # Latest
# Supported: 11, 12, 13, 14, 15, 16
```

### Backup Configuration
Edit `terraform/main.tf` (google_sql_database_instance):
```hcl
backup_configuration {
  enabled                        = true
  point_in_time_recovery_enabled = true
  backup_retention_settings {
    retained_backups = 90  # Keep 90 backups
    retention_unit   = "COUNT"
  }
}
```

---

## Cloud Run Configuration

### More Memory
```hcl
cloud_run_memory = 1024  # 1 GB
# Options: 128, 256, 512, 1024, 2048, 4096 MB
```

### Custom Image
```hcl
cloud_run_image = "gcr.io/my-org/my-app:v1.2.3"
```

### Environment Variables
Edit `terraform/main.tf` (google_cloud_run_service container):
```hcl
env {
  name  = "LOG_LEVEL"
  value = "DEBUG"
}
env {
  name  = "API_KEY"
  value = "secret-value"  # Use Secret Manager in production!
}
```

---

## Network Configuration

### Restrict Firewall
```hcl
allowed_source_ranges = [
  "192.0.2.0/24",    # Office VPN
  "198.51.100.0/24"  # Data center
]
```

### Disable Firewall
```hcl
enable_firewall_rules = false
# No incoming access restrictions
```

### Change VPC CIDR
Edit `terraform/main.tf`:
```hcl
resource "google_compute_subnetwork" "default" {
  ip_cidr_range = "10.1.0.0/24"  # Change from 10.0.0.0/24
}
```

---

## Security Enhancements

### Use Secret Manager
Create secret:
```bash
gcloud secrets create postgres-password --data-file=- <<< "secure-password"
```

Reference in Terraform:
```hcl
resource "google_sql_user" "app_user" {
  password = data.google_secret_manager_secret_version.postgres_password.secret_data
}
```

### Require SSL
Edit `terraform/main.tf`:
```hcl
ip_configuration {
  require_ssl = true
}
```

### Private IP Only
Edit `terraform/main.tf`:
```hcl
ip_configuration {
  ipv4_enabled = false  # No public IP
}
```

---

## Regional Configuration

### Multi-Region Setup
```hcl
region = "europe-west1"
# Other regions: asia-northeast1, us-west1, etc.
```

### High Availability (Multi-Zone)
Edit `terraform/main.tf`:
```hcl
settings {
  availability_type = "REGIONAL"  # Already set
}
```

---

## Monitoring & Logging

### Enable Audit Logging
Edit `terraform/main.tf`:
```hcl
resource "google_sql_database_instance" "postgres" {
  settings {
    database_flags {
      name  = "log_statement"
      value = "all"  # Log all SQL
    }
  }
}
```

### Connect CloudSQL Insights
Edit `terraform/main.tf`:
```hcl
settings {
  insights_config {
    query_insights_enabled  = true
    query_string_length     = 1024
    record_application_tags = false
  }
}
```

---

## Cost Optimization

### Reduce Tier
```hcl
database_tier = "db-f1-micro"  # Smallest, cheapest
```

### Reduce Cloud Run Memory
```hcl
cloud_run_memory = 128  # Minimum
```

### Regional Storage
```hcl
region = "us-central1"  # Cheaper than others
```

---

## Advanced: Add dbt

Integrate dbt for data transformation:

1. Modify Cloud Run image to include dbt:
   ```hcl
   cloud_run_image = "gcr.io/my-org/dbt-runner:latest"
   ```

2. Add environment variables:
   ```hcl
   env {
     name  = "DBT_PROFILES_DIR"
     value = "/app"
   }
   env {
     name  = "DBT_THREADS"
     value = "4"
   }
   ```

3. Use validators (gcp-postgres-validators):
   ```python
   from gcp_postgres_validators import DbtProject
   
   project = DbtProject(
       manifest_path="target/manifest.json",
       postgres_host=instance.private_ip_address,
       postgres_schema="{{ var('dbt_schema') }}"
   )
   ```

---

## Testing Your Changes

Before deploying:
```bash
cd terraform

# Validate syntax
terraform fmt
terraform validate

# Plan changes
terraform plan \
  -var="project_id=YOUR-PROJECT" \
  -var="name_prefix=myapp"

# Review plan output
# Then apply when ready
```

---

## Common Patterns

### Development Environment
```hcl
name_prefix   = "dev"
environment   = "dev"
database_tier = "db-f1-micro"
cloud_run_memory = 256
allowed_source_ranges = ["0.0.0.0/0"]  # Open for dev
```

### Staging Environment
```hcl
name_prefix   = "staging"
environment   = "staging"
database_tier = "db-n1-standard-1"
cloud_run_memory = 512
allowed_source_ranges = ["192.0.2.0/24"]  # Restricted
```

### Production Environment
```hcl
name_prefix   = "prod"
environment   = "prod"
database_tier = "db-n1-standard-2"
cloud_run_memory = 1024
allowed_source_ranges = ["192.0.2.0/24", "198.51.100.0/24"]
```

---

For more help, see:
- [SETUP.md](SETUP.md) — Detailed configuration
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) — Common issues
- [ARCHITECTURE.md](ARCHITECTURE.md) — Design decisions
