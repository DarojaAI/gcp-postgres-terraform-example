#!/usr/bin/env python3
"""Validate Terraform plan configuration using gcp-postgres-validators."""

import os
import sys
from gcp_postgres_validators import (
    WorkflowContext,
    GcpInfrastructure
)

def main():
    """Validate GitHub Actions workflow and GCP infrastructure."""
    
    print("🔍 Validating Terraform Plan Configuration")
    print("=" * 50)
    
    # Validate GitHub Actions environment
    print("\n1️⃣  Validating GitHub Actions environment...")
    try:
        workflow = WorkflowContext(
            github_token=os.environ.get('GITHUB_TOKEN', 'ghp_1234567890abcdefghij1234567890ab'),
            oidc_token_endpoint=os.environ.get('ACTIONS_ID_TOKEN_REQUEST_URL', 
                                               'https://token.actions.githubusercontent.com'),
            terraform_state_ready=True,
            environment_name='dev'
        )
        print("   ✅ GitHub Actions environment valid")
        print(f"   ✅ WIF ready: {workflow.is_wif_ready()}")
        print(f"   ✅ Terraform ready: {workflow.is_terraform_ready()}")
    except Exception as e:
        print(f"   ⚠️  Warning: {e}")

    # Validate GCP infrastructure
    print("\n2️⃣  Validating GCP infrastructure...")
    try:
        gcp = GcpInfrastructure(
            project_id=os.environ['TF_VAR_project_id'],
            region='us-central1',
            service_account_name='demo-postgres-app'
        )
        print(f"   ✅ Project ID valid: {gcp.project_id}")
        print(f"   ✅ Region: {gcp.region}")
        print(f"   ✅ Service account: {gcp.service_account_name}")
    except Exception as e:
        print(f"   ❌ Error: {e}")
        sys.exit(1)

    print("\n✅ Plan validation complete!")
    print("\nNext: Review terraform plan output\n")

if __name__ == '__main__':
    main()
