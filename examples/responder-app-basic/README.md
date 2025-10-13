# Basic Responder App Example

Creates a basic RTB Fabric responder application without managed endpoints.

## Features

- **No managed endpoints** - RTB Fabric will not automatically discover backend instances
- **Manual endpoint management** - You manage your own load balancers or endpoints
- **Minimal configuration** - Only requires basic networking and app details

## Prerequisites

- VPC with subnets and security groups
- Your own load balancer or endpoint management solution

## Usage

1. Update `main.tf` with your:
   - AWS resource IDs (VPC, subnets, security groups)
   - Application details (name, port, DNS name)
2. Run:
```bash
terraform init
terraform plan
terraform apply

# View outputs after deployment
terraform output

# Get specific output
terraform output responder_app_id
```

## Configuration

This example uses:
- **HTTP protocol** on port 8080
- **Single subnet** deployment
- **No managed endpoint configuration** - you handle backend discovery

## Resources Created

- 1 RTB Fabric Responder App (basic configuration)

## Use Cases

- When you have existing load balancers
- When you want full control over endpoint management
- When you don't need EKS or ASG integration
- For testing RTB Fabric core functionality