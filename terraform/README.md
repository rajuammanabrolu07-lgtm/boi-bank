# Terraform (Phase 3)

Provisions ALL AWS infrastructure as code:
- VPC (public + private subnets, single NAT gateway to save cost)
- EKS cluster (single cluster, one node group)
- ECR repositories (one per service)
- IAM / IRSA roles (least-privilege, no static keys in pods)
- ALB controller IAM, RDS (Postgres) for staging/prod

Workflow: `terraform apply` to build, `terraform destroy` to tear down.
Coming in Phase 3.
