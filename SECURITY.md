# Security Policy

## Security Scanning

This repository uses multiple security scanning tools to ensure code quality and security:

### Tools Used

- **TFSec**: Terraform security scanner that detects potential security issues
- **Checkov**: Static code analysis tool for infrastructure as code
- **TFLint**: Terraform linter for catching errors and enforcing best practices

### Running Security Scans

#### Local Development

Install all tools:
```bash
make install-tools
```

Run individual scans:
```bash
make tfsec      # Security vulnerabilities
make checkov    # Compliance and best practices  
make tflint     # Terraform linting
make security   # Run all security scans
```

#### GitHub Actions

Security scans run automatically on:
- Pull requests to main/master branch
- Manual workflow dispatch

The workflow can be triggered with different scan levels:
- `full`: All checks (default)
- `security-only`: Only TFSec and Checkov
- `lint-only`: Only formatting and TFLint

### Configuration Files

- `.tfsec.yml`: TFSec configuration and exclusions
- `.checkov.yml`: Checkov configuration and skip rules
- `.tflint.hcl`: TFLint rules and AWS plugin configuration

### Reporting Security Issues

If you discover a security vulnerability, please report it by:

1. **Do not** create a public GitHub issue
2. Email the maintainers directly
3. Include detailed information about the vulnerability
4. Allow time for the issue to be addressed before public disclosure

### Security Best Practices

When contributing to this repository:

1. Run security scans locally before submitting PRs
2. Address any HIGH or CRITICAL findings
3. Document any intentional security exceptions
4. Keep dependencies up to date
5. Follow AWS security best practices for Terraform modules

### Excluded Checks

Some security checks are intentionally excluded for this module:

- **Examples**: Simplified configurations in example directories may skip certain security controls for clarity
- **Service Roles**: IAM roles created for AWS services may require broader permissions
- **Development**: Some checks are relaxed for development and testing scenarios

See configuration files for complete list of exclusions and rationale.