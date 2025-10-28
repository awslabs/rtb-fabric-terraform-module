# RTB Fabric Responder Gateway with EKS Endpoints (Manual Setup)

This example demonstrates how to configure an RTB Fabric responder gateway with EKS managed endpoints using a pre-configured customer role.

## Prerequisites

Before running this example, you must manually configure:

1. **Customer Role Trust Policy**: The customer role must trust RTB Fabric service principals
2. **EKS Policy Attachment**: The customer role must have AmazonEKSViewPolicy attached
3. **EKS Access Entry**: The customer role must have access to the EKS cluster
4. **Kubernetes RBAC**: The required Role and RoleBinding must exist in the target namespace

## Required Trust Policy

Your customer role must have the following trust policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "rtbfabric.amazonaws.com",
          "rtbfabric-endpoints.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

## Required IAM Policy

Attach the following AWS managed policy to your customer role:
- `arn:aws:iam::aws:policy/AmazonEKSViewPolicy`

## Required EKS Discovery Role

Create an EKS Discovery Role for Kubernetes API access (using custom enterprise naming):

```bash
# Create the role with trust policy for your account
aws iam create-role \
  --role-name MyCompany-RTBFabric-EKS-Discovery-Role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::123456789012:root"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }'

# Attach minimal EKS permissions
aws iam put-role-policy \
  --role-name MyCompany-RTBFabric-EKS-Discovery-Role \
  --policy-name MyCompany-RTBFabric-EKS-Discovery-Policy \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "eks:DescribeCluster"
        ],
        "Resource": "arn:aws:eks:us-east-1:123456789012:cluster/my-eks-cluster"
      }
    ]
  }'
```

## Required EKS Access

Create an EKS access entry for your customer role:

```bash
aws eks create-access-entry \
  --cluster-name my-eks-cluster \
  --principal-arn arn:aws:iam::123456789012:role/MyPreConfiguredRTBFabricRole \
  --type STANDARD

aws eks associate-access-policy \
  --cluster-name my-eks-cluster \
  --principal-arn arn:aws:iam::123456789012:role/MyPreConfiguredRTBFabricRole \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy \
  --access-scope type=namespace,namespaces=default
```

## Required Kubernetes RBAC

Create the following Kubernetes resources in your target namespace:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: rtbfabric-endpoint-reader
rules:
- apiGroups: [""]
  resources: ["endpoints"]
  resourceNames: ["bidder"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: rtbfabric-endpoint-reader
  namespace: default
subjects:
- kind: User
  name: MyPreConfiguredRTBFabricRole
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: rtbfabric-endpoint-reader
  apiGroup: rbac.authorization.k8s.io
```

## Usage

1. Update the variables in `main.tf` with your specific values
2. Ensure all prerequisites are met
3. Run:

```bash
terraform init
terraform plan
terraform apply
```

## Validation

The module will validate that all required configurations are in place before creating resources. If validation fails, you'll receive clear error messages with remediation steps.