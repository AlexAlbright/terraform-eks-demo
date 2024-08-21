data "aws_caller_identity" "current" {}
 
locals {
  account_id = data.aws_caller_identity.current.account_id

 eks_principals = concat(
    [for user in var.eks_users : "arn:aws:iam::${local.account_id}:user/${user}"],
    [for role in var.eks_roles : "arn:aws:iam::${local.account_id}:role/${role}"]
  )
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.5.0"

  cluster_name                    = "test_cluster"
  cluster_version                 = "1.30"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = var.eks_public_access

  subnet_ids = var.private_subnets
  vpc_id = var.vpc_id

  access_entries = {
    for v in local.eks_principals : v => {
      principal_arn = v
      policy_associations = {
        admin = {
          # Make these principals cluster admins
          # https://docs.aws.amazon.com/eks/latest/userguide/access-policies.html#access-policy-permissions
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}
