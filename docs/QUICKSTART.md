# Quick Start (5 Minutes)

Deploy cloud SQL + Cloud Run in 5 minutes.

---

## Step 1: Fork Repository (1 min)

1. Click **Fork** at top right of this repo
2. Clone to your machine:
   ```bash
   git clone https://github.com/YOUR-ORG/gcp-postgres-terraform-example.git
   cd gcp-postgres-terraform-example
   ```

---

## Step 2: Add GitHub Secrets (2 min)

1. Go to your forked repo
2. **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add secret:
   ```
   Name:  GCP_PROJECT_ID
   Value: your-gcp-project-id-123456
   ```
5. Save

---

## Step 3: Deploy (2 min)

### Option A: Web UI (Easiest)

1. Go to **Actions** tab
2. Click **Terraform Apply**
3. Click **Run workflow** (on main branch)
4. Wait 2-3 minutes for deployment

### Option B: Local CLI

```bash
cd terraform

# Initialize
terraform init

# Plan
terraform plan \
  -var="project_id=YOUR-PROJECT-ID" \
  -var="name_prefix=demo"

# Apply
terraform apply \
  -var="project_id=YOUR-PROJECT-ID" \
  -var="name_prefix=demo"
```

---

## Step 4: Verify (30 sec)

Get Cloud Run URL:
```bash
# From Terraform output
terraform output cloud_run_service_url

# Or from GCP Console
# Cloud Run → demo-api → Copy service URL
```

Visit URL in browser → Should see "Hello World" ✅

---

## What Got Created?

✅ Cloud SQL PostgreSQL instance  
✅ Cloud Run application  
✅ Private VPC network  
✅ Service accounts with IAM bindings  
✅ Firewall rules (optional)  

---

## Next Steps

- **Customize**: See [CUSTOMIZATION.md](CUSTOMIZATION.md)
- **Set up production**: See [SETUP.md](SETUP.md)
- **Troubleshoot**: See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Understand design**: See [ARCHITECTURE.md](ARCHITECTURE.md)

---

## Cleanup

Remove all resources:
```bash
cd terraform
terraform destroy \
  -var="project_id=YOUR-PROJECT-ID" \
  -var="name_prefix=demo"
```

---

**Done!** You now have a working PostgreSQL + Cloud Run deployment. 🎉
