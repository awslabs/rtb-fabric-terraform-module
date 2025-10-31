# RTB Fabric Terraform Module v0.1.0 🎉

**Release Date**: October 30, 2024  
**GitHub Release**: https://github.com/awslabs/rtb-fabric-terraform-module/releases/tag/v0.1.0

## 🚀 First Official Release

This is the initial release of the RTB Fabric Terraform module with full GA API support!

## 📦 Installation

### Pinned Version (Recommended)
```hcl
module "rtb_fabric" {
  source = "github.com/awslabs/rtb-fabric-terraform-module?ref=v0.1.0"
  
  requester_gateway = {
    create = true
    description = "My RTB requester gateway"
    vpc_id = "vpc-12345"
    subnet_ids = ["subnet-12345"]
    security_group_ids = ["sg-12345"]
  }
}
```

### Latest Version
```hcl
module "rtb_fabric" {
  source = "github.com/awslabs/rtb-fabric-terraform-module"
  # Configuration here
}
```

## ✨ Key Features

- **🔄 Auto-Discovery**: Automatic VPC, subnet, and security group discovery from EKS clusters
- **🔐 Flexible Authentication**: Role name configuration with dynamic ARN construction  
- **📋 Multiple Examples**: 6 comprehensive examples covering different use cases
- **✅ Validation**: Input validation and clear error messages
- **🏢 Enterprise Ready**: Custom IAM role naming conventions

## 📚 Examples Included

| Example | Description | Use Case |
|---------|-------------|----------|
| `requester-gateway` | Simple requester with EKS auto-discovery | Publisher/demand-side setup |
| `responder-gateway-eks` | EKS managed endpoints | Bidder with Kubernetes services |
| `responder-gateway-basic` | Manual network configuration | Custom networking setup |
| `responder-gateway-asg` | Auto Scaling Group endpoints | Traditional ASG-based bidders |
| `responder-gateway-eks-hybrid` | Custom IAM role creation | Enterprise compliance |
| `e2e-test` | Complete setup with link | Full RTB Fabric deployment |

## 🛠️ Quick Start

1. **Choose an example**:
   ```bash
   cd examples/responder-gateway-eks/
   ```

2. **Configure your settings**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your cluster name
   ```

3. **Deploy**:
   ```bash
   terraform init
   terraform plan  
   terraform apply
   ```

## 🔧 Configuration Management

- **No More Hardcoded Values**: All account-specific values are now configurable
- **Template Files**: Each example includes `terraform.tfvars.example`
- **Backward Compatible**: Existing deployments continue to work
- **Clear Documentation**: Comprehensive README files for each example

## 🎯 What's New in GA API

- **New Resource Types**: `RequesterGateway`, `ResponderGateway`, `Link`
- **Enhanced Features**: Better managed endpoints, improved logging
- **Simplified Configuration**: Cleaner variable structure
- **Better Validation**: More robust input validation

## 📖 Documentation

- **Main README**: Complete module documentation
- **Example READMEs**: Detailed setup guides for each example
- **CHANGELOG**: Full change history
- **Troubleshooting**: Common issues and solutions

## 🤝 Contributing

This module is part of the AWS Labs organization. Contributions, issues, and feature requests are welcome!

## 📄 License

This project is licensed under the Apache License 2.0.

---

**Happy deploying!** 🚀