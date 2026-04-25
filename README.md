# GCP PostgreSQL + Terraform Example

Complete, working example of deploying Cloud SQL PostgreSQL + Cloud Run using Terraform with integrated validators.

**Status**: ✅ Production-ready example  
**Framework**: Terraform 1.5+  
**Validators**: [gcp-postgres-validators](https://github.com/DarojaAI/gcp-postgres-validators)

---

## Quick Start (5 minutes)

### 1. Fork & Clone
```bash
# Fork this repository
# Then clone locally
git clone https://github.com/your-org/gcp-postgres-terraform-example.git
cd gcp-postgres-terraform-example
```

### 2. Set Up Secrets
```bash
# Add to GitHub Secrets (Settings → Secrets and variables)
GCP_PROJECT_ID: your-gcp-project-id
```

### 3. Configure & Deploy
```bash
# Update variables
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Deploy
terraform init
terraform plan
terraform apply
```

### 4. Verify Deployment
```bash
# Visit the Cloud Run URL from outputs
# Endpoints should respond with hello world

# Check Cloud SQL
gcloud sql connect demo-postgres-dev \
  --user=app_user \
  --instance=demo-postgres-dev
```

---

## What This Example Includes

### Infrastructure
- ✅ Cloud SQL PostgreSQL instance (regional, encrypted)
- ✅ Private VPC network with Cloud SQL private connectivity
- ✅ Cloud Run service with PostgreSQL connection
- ✅ Service accounts with least-privilege IAM
- ✅ Firewall rules for access control

### Automation
- ✅ GitHub Actions: terraform-plan.yml (on PR)
- ✅ GitHub Actions: terraform-apply.yml (on merge)
- ✅ Validator integration: Pre-deployment checks
- ✅ Automated testing and validation

### Documentation
- ✅ QUICKSTART.md (5-minute setup)
- ✅ CUSTOMIZATION.md (adapt for your project)
- ✅ TROUBLESHOOTING.md (common issues)
- ✅ ARCHITECTURE.md (design decisions)
- ✅ SETUP.md (detailed step-by-step)

---

## File Structure

```
.
├── terraform/
│   ├── main.tf              # Cloud SQL, Cloud Run, VPC
│   ├── variables.tf         # Input variables
│   ├── outputs.tf           # Output values
│   ├── versions.tf          # Provider versions
│   └── terraform.tfvars.example
├── .github/workflows/
│   ├── terraform-plan.yml   # Plan on PR
│   └── terraform-apply.yml  # Apply on main
├── scripts/
│   ├── validate-plan.py     # Pre-plan validation
│   └── validate-apply.py    # Post-apply validation
├── docs/
│   ├── QUICKSTART.md
│   ├── SETUP.md
│   ├── CUSTOMIZATION.md
│   ├── TROUBLESHOOTING.md
│   └── ARCHITECTURE.md
└── README.md (this file)
```

---

## Customization

### Change Resource Names
```hcl
# In terraform/terraform.tfvars
name_prefix = "myapp"        # Changes all resource names
environment = "staging"      # Affects naming and configuration
```

### Scale Database
```hcl
database_tier = "db-n1-standard-2"  # Larger instance
```

### Adjust Cloud Run
```hcl
cloud_run_memory = 512              # More memory
cloud_run_image  = "gcr.io/my-org/my-image:latest"
```

### Restrict Firewall
```hcl
allowed_source_ranges = ["192.0.2.0/24"]  # Only this range
```

See [CUSTOMIZATION.md](docs/CUSTOMIZATION.md) for more options.

---

## Architecture

### VPC & Networking
- Private VPC for Cloud SQL
- Cloud Run → Private Service Connection → Cloud SQL
- No public IP exposure for database

### Security
- Cloud SQL: Regional setup + automated backups
- Cloud Run: Least-privilege service account
- IAM: Only required roles (cloudsql.client, cloudsql.instanceUser)
- Network: Private by default, restricted firewall

### Deployment Flow
1. **Plan**: Validators check config → Terraform plan
2. **Review**: Manual approval (on PR)
3. **Apply**: Terraform creates resources → Post-apply validation
4. **Monitor**: Deployment logs + summary

See [ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed design.

---

## Validators Integration

This example uses [gcp-postgres-validators](https://github.com/DarojaAI/gcp-postgres-validators) for deployment validation:

- **WorkflowContext**: Validates GitHub Actions environment
- **GcpInfrastructure**: Checks GCP project setup
- **TerraformOutput**: Validates deployment outputs

### Pre-Plan Validation
```bash
python3 scripts/validate-plan.py
```

### Post-Apply Validation
```bash
python3 scripts/validate-apply.py
```

See docs for validator setup.

---

## Prerequisites

### Local Setup
- Terraform 1.5+
- GCP Cloud SDK
- Python 3.9+
- git

### GCP Project
- Cloud SQL API enabled
- Cloud Run API enabled
- Compute Engine API enabled
- Service Networking API enabled

### GitHub
- Repository secrets configured (GCP_PROJECT_ID)
- Workflows enabled

See [SETUP.md](docs/SETUP.md) for detailed prerequisites.

---

## Troubleshooting

### Common Issues

**"Permission denied" when applying**
→ See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md#permissions)

**"Private service connection failed"**
→ See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md#private-connection)

**"Cloud Run can't connect to Cloud SQL"**
→ See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md#cloud-run-connection)

For more, see [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

---

## GitHub Secrets

Required for CI/CD:

```
GCP_PROJECT_ID     # Your GCP project ID
```

Optional (for production deployments):
```
WORKLOAD_IDENTITY_PROVIDER    # For WIF
SERVICE_ACCOUNT_EMAIL         # Service account to impersonate
```

---

## Next Steps

1. **Deploy**: Follow [QUICKSTART.md](docs/QUICKSTART.md) (5 min)
2. **Customize**: Edit [terraform/terraform.tfvars](terraform/terraform.tfvars.example)
3. **Secure**: Review IAM and firewall rules in main.tf
4. **Monitor**: Check Cloud SQL and Cloud Run logs
5. **Scale**: Use [CUSTOMIZATION.md](docs/CUSTOMIZATION.md) for production settings

---

## Support

- 📚 Documentation: See `docs/` folder
- 🔗 Validators: [gcp-postgres-validators](https://github.com/DarojaAI/gcp-postgres-validators)
- 💡 Issues: GitHub Issues
- 📝 Contributing: Pull requests welcome!

---

## License

This example is provided as-is for educational purposes.

---

## Related Resources

- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Cloud SQL Best Practices](https://cloud.google.com/sql/docs/postgres/best-practices)
- [Cloud Run Security](https://cloud.google.com/run/docs/securing/managing-access)
- [gcp-postgres-validators](https://github.com/DarojaAI/gcp-postgres-validators)

---

**Ready to deploy?** → Start with [QUICKSTART.md](docs/QUICKSTART.md) ✨
