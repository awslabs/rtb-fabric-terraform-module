# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-10-30

### Added
- Initial release of RTB Fabric Terraform module with GA API support
- Support for RTB Fabric requester and responder gateways
- RTB Fabric Link resources for connecting gateways
- EKS managed endpoints with automatic cluster discovery
- Auto Scaling Group managed endpoints
- Configurable examples using terraform.tfvars approach
- Comprehensive documentation and setup guides

### Features
- **Auto-Discovery**: Automatic VPC, subnet, and security group discovery from EKS clusters
- **Flexible Authentication**: Role name configuration with dynamic ARN construction
- **Multiple Examples**: Basic, EKS, ASG, hybrid, and end-to-end configurations
- **Validation**: Input validation and clear error messages for common misconfigurations
- **Enterprise Ready**: Support for custom IAM role naming conventions

### Examples Included
- `requester-gateway`: Simple requester gateway with EKS auto-discovery
- `responder-gateway-eks`: EKS responder gateway with managed endpoints
- `responder-gateway-basic`: Manual network configuration
- `responder-gateway-asg`: Auto Scaling Group managed endpoints
- `responder-gateway-eks-hybrid`: Custom IAM role creation example
- `e2e-test`: Complete end-to-end setup with requester, responder, and link

### Configuration Management
- Extracted hardcoded values into configurable variables
- Template files (terraform.tfvars.example) for easy customization
- Backward compatibility with existing deployments
- Clear separation between account-specific and application-level settings

[0.1.0]: https://github.com/awslabs/rtb-fabric-terraform-module/releases/tag/v0.1.0