#!/usr/bin/env python3
"""Validate Terraform apply output using gcp-postgres-validators."""

import json
import os
import sys
from gcp_postgres_validators import TerraformOutput

def main():
    """Validate Terraform deployment outputs."""
    
    print("🔍 Validating Terraform Deployment")
    print("=" * 50)
    
    # Load Terraform outputs
    tf_outputs_path = os.environ.get('TERRAFORM_OUTPUTS', 'terraform/terraform.tfstate')
    
    try:
        with open(tf_outputs_path, 'r') as f:
            outputs = json.load(f)
        print(f"\n✅ Loaded outputs from {tf_outputs_path}")
    except Exception as e:
        print(f"❌ Error loading outputs: {e}")
        sys.exit(1)

    # Extract individual outputs
    print("\n📊 Deployment Outputs:")
    try:
        instance_conn = outputs.get('instance_connection_name', {}).get('value')
        instance_ip = outputs.get('instance_ip_address', {}).get('value')
        cloud_run_url = outputs.get('cloud_run_service_url', {}).get('value')
        firewall_rules = outputs.get('firewall_rules_created', {}).get('value', 0)
        
        print(f"  • Instance connection: {instance_conn}")
        print(f"  • Instance IP: {instance_ip}")
        print(f"  • Cloud Run URL: {cloud_run_url}")
        print(f"  • Firewall rules: {firewall_rules}")
    except Exception as e:
        print(f"⚠️  Warning: Could not extract outputs: {e}")
        return

    # Validate deployment
    print("\n✅ Validating deployment with gcp-postgres-validators...")
    try:
        deployment = TerraformOutput(
            instance_connection_name=instance_conn,
            instance_ip_address=instance_ip,
            cloud_run_service_url=cloud_run_url,
            firewall_rules_created=firewall_rules
        )
        
        summary = deployment.deployment_summary()
        print("\n📋 Deployment Summary:")
        print(f"  • Cloud SQL Instance: {summary.get('cloud_sql_instance')}")
        print(f"  • Private IP: {summary.get('private_ip')}")
        print(f"  • Cloud Run Service: {summary.get('cloud_run_service')}")
        print(f"  • Firewall Rules: {summary.get('firewall_rules')}")
        
        conn_info = deployment.connection_info()
        print("\n🔌 Connection Info:")
        for key, value in conn_info.items():
            print(f"  • {key}: {value}")
        
        print("\n✅ Deployment validation successful!")
        print("\n🎉 Your infrastructure is ready to use!\n")
        
    except Exception as e:
        print(f"❌ Validation failed: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
